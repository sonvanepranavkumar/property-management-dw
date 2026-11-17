FROM apache/airflow:3.3.1

USER root
RUN python -m venv /opt/dbt_venv \
    && /opt/dbt_venv/bin/pip install --no-cache-dir \
        "dbt-core>=1.10.5,<2" \
        "dbt-postgres>=1.10,<2"
USER airflow