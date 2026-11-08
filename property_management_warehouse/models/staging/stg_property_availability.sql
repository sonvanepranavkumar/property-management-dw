SELECT
    availability_id,
    property_id,
    effective_from,
    effective_to,
    is_available,
    availability_reason,
    created_at
FROM {{ source('raw', 'property_availability') }}