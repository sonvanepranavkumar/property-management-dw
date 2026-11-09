WITH paid_allocations AS (

    SELECT
        a.charge_id,
        a.allocated_amount,
        p.payment_date
    FROM {{ ref('stg_payment_allocations') }} AS a
    INNER JOIN {{ ref('stg_rent_payments') }} AS p
        ON a.payment_id = p.payment_id
    WHERE p.payment_status = 'paid'

),

allocations_per_charge AS (

    SELECT
        charge_id,
        SUM(allocated_amount)  AS amount_paid,
        COUNT(*)               AS payment_count,
        MAX(payment_date)      AS last_payment_date
    FROM paid_allocations
    GROUP BY charge_id

)

SELECT
    c.charge_id,
    c.lease_id,
    c.period_start,
    c.period_end,
    c.due_date,
    c.amount_due,
    c.charge_status,
    COALESCE(a.amount_paid, 0)    AS amount_paid,
    COALESCE(a.payment_count, 0)  AS payment_count,
    a.last_payment_date
FROM {{ ref('stg_rent_charges') }} AS c
LEFT JOIN allocations_per_charge AS a
    ON c.charge_id = a.charge_id