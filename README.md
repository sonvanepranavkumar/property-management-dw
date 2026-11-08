# Property Management Data Warehouse

An end to end data warehouse project built using PostgreSQL, dbt and SQL to model and analyse rental income, rent payments and property performance data.

## Features

- Relational source schema for properties, tenants, leases, rent charges, rent payments, payment allocations, expenses and property availability
- Primary keys, foreign keys, unique and check constraints to enforce data integrity
- Rent charges separated from payments through payment allocations, supporting partial payments and arrears tracking
- Time-bound property availability for occupancy analysis
- Sample data covering partial, failed and pending payments
- dbt staging models for all 8 source tables
- dbt tests for unique and not null values
- SQL validation queries for source row counts and table relationships

## Technology Stack

- PostgreSQL
- dbt
- SQL

## Getting Started

### Prerequisites

- PostgreSQL
- Python
- dbt with the Postgres adapter (dbt-postgres)

### Installation

1. Clone the repository
2. Run `sql/01_create_tables.sql` to create the raw schema and tables
3. Run `sql/02_insert_sample_data.sql` to load the sample data
4. Run `sql/03_validate_source_data.sql` to check the source data
5. Configure your dbt profile to connect to PostgreSQL
6. Run `dbt build` from the `property_management_warehouse` folder to build and test the models

## Data Model

- **Properties:** Property details including type, address, city, postcode and bedrooms
- **Tenants:** Tenant contact details
- **Leases:** Links tenants to properties with agreed monthly rent, due day and lease status
- **Rent Charges:** Monthly rent due for each lease
- **Rent Payments:** Payments received with method, status and transaction reference
- **Payment Allocations:** Links payments to the rent charges they settle
- **Expenses:** Property costs such as repairs and maintenance
- **Property Availability:** Periods when a property is available or unavailable to rent

## Data Quality

The project applies data quality rules to ensure:

- Unique and non null identifiers
- Valid relationships between properties, tenants, leases, charges and payments
- Positive rent, payment and expense amounts
- Valid date ranges for leases, rent periods and availability
- Allowed values for lease, charge and payment statuses
- No duplicate rent charges for the same lease and period
