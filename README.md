# Property Management Data Warehouse

An end to end data warehouse project built using PostgreSQL, dbt and SQL to model and analyse rental income, rent payments and property performance data orchestrated with Apache Airflow and run in Docker.

## Features

- Relational source schema for properties, tenants, leases, rent charges, rent payments, payment allocations, expenses and property availability
- Primary keys, foreign keys, unique and check constraints to enforce data integrity
- Rent charges separated from payments through payment allocations, supporting partial payments and arrears tracking
- Time-bound property availability for occupancy analysis
- Sample data covering partial, failed and pending payments
- Layered dbt project (staging, intermediate, marts) with a star schema of a rent charge fact table and property and tenant dimensions
- Rent charge fact table calculating amount outstanding, collection status, days overdue and on-time payment for each charge
- dbt tests for uniqueness, not null values, relationships and accepted values
- SQL validation queries for source row counts and table relationships
- Apache Airflow DAG that checks the source data, then builds and tests each dbt layer daily

## Technology Stack

- PostgreSQL
- dbt
- SQL
- Apache Airflow
- Docker

## Pipeline

The Airflow DAG `property_management_dw` runs daily:

```
check_source_data -> dbt_build_staging -> dbt_build_intermediate -> dbt_build_marts
```

- **check_source_data** fails if any raw source table is empty
- **dbt_build_staging / intermediate / marts** build and test one dbt layer at a time. If a test fails, the later layers do not run so bad data never reaches the marts

Each run passes its date to dbt as `as_of_date` which is used to calculate overdue rent. A different date can be entered when triggering a run manually to rebuild a past report.

## Getting Started

### Option 1: Run with Airflow (Docker)

#### Prerequisites

- Docker Desktop

#### Start

```bash
docker compose up -d --build
```

On first start, the warehouse database runs `sql/01_create_tables.sql` and `sql/02_insert_sample_data.sql` automatically.

Open http://localhost:8080, switch on the `property_management_dw` DAG and start a run.

#### Check the results

Connect to the warehouse:

```bash
docker compose exec warehouse-db psql -U dw_user -d property_management
```

List the tables and views built by dbt:

```sql
\dt analytics.*
\dv analytics.*
```

Then query any of them. For example:

```sql
SELECT * FROM analytics.fct_rent_charges LIMIT 10;
```

The warehouse is also available from your machine on port 5433 (user `dw_user`, password `dw_password`).

#### Stop

```bash
docker compose down      # stop, keep data
docker compose down -v   # stop and delete data (sample data reloads on next start)
```

#### Notes

The default credentials and disabled Airflow login are for local development only.

### Option 2: Run manually

#### Prerequisites

- PostgreSQL
- Python
- dbt with the Postgres adapter (dbt-postgres)

#### Installation

1. Clone the repository
2. Run `sql/01_create_tables.sql` to create the raw schema and tables
3. Run `sql/02_insert_sample_data.sql` to load the sample data
4. Run `sql/03_validate_source_data.sql` to check the source data
5. Configure your dbt profile to connect to PostgreSQL
6. Run `dbt build` from the `property_management_warehouse` folder to build and test the models

## Data Model

### Source tables

- **Properties:** Property details including type, address, city, postcode and bedrooms
- **Tenants:** Tenant contact details
- **Leases:** Links tenants to properties with agreed monthly rent, due day and lease status
- **Rent Charges:** Monthly rent due for each lease
- **Rent Payments:** Payments received with method, status and transaction reference
- **Payment Allocations:** Links payments to the rent charges they settle
- **Expenses:** Property costs such as repairs and maintenance
- **Property Availability:** Periods when a property is available or unavailable to rent

### Warehouse models

- **int_rent_charge_payments:** Total amount paid, payment count and last payment date for each rent charge counting successful payments only
- **fct_rent_charges:** One row per rent charge with amount due, amount paid, amount outstanding, collection status, overdue flag, days overdue and on-time flag
- **dim_properties:** One row per property
- **dim_tenants:** One row per tenant including full name

## Data Quality

The project applies data quality rules to ensure:

- Unique and non null identifiers
- Valid relationships between properties, tenants, leases, charges and payments
- Positive rent, payment and expense amounts
- Valid date ranges for leases, rent periods and availability
- Allowed values for lease, charge, payment and collection statuses
- No duplicate rent charges for the same lease and period
- No empty source tables before the dbt build runs
