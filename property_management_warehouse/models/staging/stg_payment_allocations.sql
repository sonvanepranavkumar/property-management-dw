SELECT
    allocation_id,
    payment_id,
    charge_id,
    allocated_amount,
    allocation_date,
    created_at
FROM {{ source('raw', 'payment_allocations') }}