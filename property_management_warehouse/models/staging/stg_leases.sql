SELECT
    lease_id,
    property_id,
    tenant_id,
    start_date,
    end_date,
    agreed_monthly_rent,
    billing_frequency,
    rent_due_day,
    lease_status,
    created_at,
    updated_at
FROM raw.leases