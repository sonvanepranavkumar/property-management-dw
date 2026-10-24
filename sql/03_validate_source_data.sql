SELECT 'properties' AS table_name, COUNT(*) AS row_count
FROM raw.properties
UNION ALL
SELECT 'tenants', COUNT(*)
FROM raw.tenants
UNION ALL
SELECT 'leases', COUNT(*)
FROM raw.leases
UNION ALL
SELECT 'rent_charges', COUNT(*)
FROM raw.rent_charges
UNION ALL
SELECT 'rent_payments', COUNT(*)
FROM raw.rent_payments
UNION ALL
SELECT 'payment_allocations', COUNT(*)
FROM raw.payment_allocations
UNION ALL
SELECT 'expenses', COUNT(*)
FROM raw.expenses
UNION ALL
SELECT 'property_availability', COUNT(*)
FROM raw.property_availability
ORDER BY table_name;

SELECT
    l.lease_id,
    p.property_name,
    t.first_name,
    t.last_name
FROM raw.leases l
JOIN raw.properties p
    ON l.property_id = p.property_id
JOIN raw.tenants t
    ON l.tenant_id = t.tenant_id;

SELECT
    payment_id,
    amount,
    payment_status
FROM raw.rent_payments
WHERE payment_status IN ('pending', 'cancelled', 'paid', 'failed', 'refunded');