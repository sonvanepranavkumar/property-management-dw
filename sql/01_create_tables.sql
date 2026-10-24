CREATE SCHEMA IF NOT EXISTS raw;

-- Properties
CREATE TABLE IF NOT EXISTS raw.properties (
    property_id INTEGER PRIMARY KEY,
    property_name VARCHAR(150) NOT NULL,
    property_type VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    postcode VARCHAR(15),
    bedrooms SMALLINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (bedrooms >= 0)
);

-- Tenants
CREATE TABLE IF NOT EXISTS raw.tenants (
    tenant_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(30),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Leases
CREATE TABLE IF NOT EXISTS raw.leases (
    lease_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES raw.properties(property_id),
    tenant_id INTEGER NOT NULL REFERENCES raw.tenants(tenant_id),
    start_date DATE NOT NULL,
    end_date DATE,
    agreed_monthly_rent NUMERIC(12,2) NOT NULL,
    billing_frequency VARCHAR(20) NOT NULL DEFAULT 'monthly',
    rent_due_day SMALLINT,
    lease_status VARCHAR(30) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date IS NULL OR end_date >= start_date),
    CHECK (agreed_monthly_rent > 0),
    CHECK (billing_frequency = 'monthly' AND rent_due_day BETWEEN 1 AND 28),
    CHECK (lease_status IN ('active', 'ended', 'cancelled'))
);

-- Rent Charges
CREATE TABLE IF NOT EXISTS raw.rent_charges (
    charge_id INTEGER PRIMARY KEY,
    lease_id INTEGER NOT NULL REFERENCES raw.leases(lease_id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    due_date DATE NOT NULL,
    amount_due NUMERIC(12,2) NOT NULL,
    charge_status VARCHAR(30) NOT NULL DEFAULT 'due',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (period_end >= period_start),
    CHECK (amount_due > 0),
    CHECK (charge_status IN ('due', 'waived', 'cancelled')),
    UNIQUE (lease_id, period_start)
);

-- Rent Payments
CREATE TABLE IF NOT EXISTS raw.rent_payments (
    payment_id INTEGER PRIMARY KEY,
    payment_date DATE,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (amount > 0),
    CHECK (payment_status IN ('pending', 'cancelled', 'paid', 'failed', 'refunded'))
);

-- Payment Allocations
CREATE TABLE IF NOT EXISTS raw.payment_allocations (
    allocation_id INTEGER PRIMARY KEY,
    payment_id INTEGER NOT NULL REFERENCES raw.rent_payments(payment_id),
    charge_id INTEGER NOT NULL REFERENCES raw.rent_charges(charge_id),
    allocated_amount NUMERIC(12,2) NOT NULL,
    allocation_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (allocated_amount > 0)
);

-- Expenses
CREATE TABLE IF NOT EXISTS raw.expenses (
    expense_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES raw.properties(property_id),
    expense_date DATE NOT NULL,
    expense_category VARCHAR(100) NOT NULL,
    description TEXT,
    amount NUMERIC(12,2) NOT NULL,
    invoice_reference VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (amount > 0)
);

-- Property Availability
CREATE TABLE IF NOT EXISTS raw.property_availability (
    availability_id INTEGER PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES raw.properties(property_id),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_available BOOLEAN NOT NULL,
    availability_reason VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (effective_to IS NULL OR effective_to >= effective_from)
);