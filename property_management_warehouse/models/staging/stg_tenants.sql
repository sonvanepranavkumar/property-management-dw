SELECT
    tenant_id,
    first_name,
    last_name,
    email,
    phone,
    created_at,
    updated_at
FROM {{ source('raw', 'tenants') }}