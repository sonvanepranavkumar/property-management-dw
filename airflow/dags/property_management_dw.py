"""
Property Management Data Warehouse - daily build.

Checks that the raw source tables have data, then builds and tests the dbt
project one layer at a time:

check_source_data -> dbt_build_staging -> dbt_build_intermediate -> dbt_build_marts

"""

import os
from datetime import datetime, timedelta

from airflow.providers.common.sql.operators.sql import SQLCheckOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG, Param

# Paths and connection come from docker-compose.yml
DBT_BIN = os.environ.get("DBT_BIN", "/opt/dbt_venv/bin/dbt")
DBT_PROJECT_DIR = os.environ.get(
    "DBT_PROJECT_DIR", "/opt/airflow/dbt/property_management_warehouse"
)
WAREHOUSE_CONN_ID = "warehouse_postgres"

# Reporting date passed to dbt as the as_of_date var used by fct_rent_charges
AS_OF_DATE = (
    "{{ params.as_of_date or "
    "(dag_run.logical_date or dag_run.run_after).strftime('%Y-%m-%d') }}"
)

SOURCE_TABLES = [
    "properties",
    "tenants",
    "leases",
    "rent_charges",
    "rent_payments",
    "payment_allocations",
    "expenses",
    "property_availability"
]

# One boolean per table. If any are false SQLCheckOperator fails the task
# i.e. if any raw table is empty.
SOURCE_CHECK_SQL = "SELECT\n" + ",\n".join(
    f"    (SELECT COUNT(*) FROM raw.{table}) > 0 AS {table}_has_rows"
    for table in SOURCE_TABLES
)


def dbt_build(layer: str) -> str:
    """Return the shell command that builds and tests one dbt layer."""
    return (
        f"{DBT_BIN} build "
        f"--select path:models/{layer} "
        "--indirect-selection buildable "
        "--vars '{\"as_of_date\": \"" + AS_OF_DATE + "\"}'"
    )


with DAG(
    dag_id="property_management_dw",
    description="Build and test the property management dbt warehouse",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    default_args={
        "retries": 1,
        "retry_delay": timedelta(minutes=2)
    },
    params={
        "as_of_date": Param(
            None,
            type=["null", "string"],
            format="date",
            description="Optional reporting date"
        ),
    },
    tags=["property-management"]
) as dag:

    check_source_data = SQLCheckOperator(
        task_id="check_source_data",
        conn_id=WAREHOUSE_CONN_ID,
        sql=SOURCE_CHECK_SQL
    )

    dbt_build_staging = BashOperator(
        task_id="dbt_build_staging",
        bash_command=dbt_build("staging"),
        cwd=DBT_PROJECT_DIR
    )

    dbt_build_intermediate = BashOperator(
        task_id="dbt_build_intermediate",
        bash_command=dbt_build("intermediate"),
        cwd=DBT_PROJECT_DIR
    )

    dbt_build_marts = BashOperator(
        task_id="dbt_build_marts",
        bash_command=dbt_build("marts"),
        cwd=DBT_PROJECT_DIR
    )

    check_source_data >> dbt_build_staging >> dbt_build_intermediate >> dbt_build_marts