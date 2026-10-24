CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.properties (
    property_id INTEGER PRIMARY KEY,
    property_name VARCHAR(150) NOT NULL,
    property_type VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    monthly_rent NUMERIC(12, 2),
    property_status VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS raw.tenants (
    tenant_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    property_id INTEGER REFERENCES raw.properties(property_id),
    move_in_date DATE,
    move_out_date DATE,
    tenant_status VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS raw.rent_payments (
    payment_id INTEGER PRIMARY KEY,
    property_id INTEGER REFERENCES raw.properties(property_id),
    tenant_id INTEGER REFERENCES raw.tenants(tenant_id),
    payment_date DATE NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS raw.expenses (
    expense_id INTEGER PRIMARY KEY,
    property_id INTEGER REFERENCES raw.properties(property_id),
    expense_date DATE NOT NULL,
    expense_category VARCHAR(100),
    description TEXT,
    amount NUMERIC(12, 2) NOT NULL
);