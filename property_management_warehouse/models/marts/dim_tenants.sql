SELECT
    tenant_id,
    first_name,
    last_name,
    first_name || ' ' || last_name AS full_name,
    email,
    phone,
    created_at,
    updated_at
FROM {{ ref('stg_tenants') }}