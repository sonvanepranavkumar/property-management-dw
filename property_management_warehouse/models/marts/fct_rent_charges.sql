WITH as_of AS (

    -- Reporting date is today by default
    SELECT
        {% if var('as_of_date', none) %}
            CAST('{{ var("as_of_date") }}' AS DATE)
        {% else %}
            CURRENT_DATE
        {% endif %}
        AS as_of_date

)

SELECT
    c.charge_id,
    c.lease_id,
    l.property_id,
    l.tenant_id,
    c.period_start,
    c.period_end,
    c.due_date,
    c.charge_status,
    c.amount_due,
    c.amount_paid,

    -- Rent owed for rent charge if it's still due
    CASE
        WHEN c.charge_status = 'due' THEN c.amount_due - c.amount_paid
        ELSE 0
    END AS rent_outstanding,

    -- Collection status of rent charge
    CASE
        WHEN c.charge_status <> 'due'       THEN c.charge_status
        WHEN c.amount_paid >= c.amount_due  THEN 'paid'
        WHEN c.amount_paid > 0              THEN 'partially_paid'
        ELSE 'unpaid'
    END AS collection_status,

    -- Is rent charge still owed past its due date
    (
        c.charge_status = 'due'
        AND c.amount_paid < c.amount_due
        AND c.due_date < a.as_of_date
    ) AS is_overdue,

    -- Days past the due date for overdue rent charges
    CASE
        WHEN c.charge_status = 'due'
            AND c.amount_paid < c.amount_due
            AND c.due_date < a.as_of_date
        THEN a.as_of_date - c.due_date
    END AS days_overdue,

    -- Was rent charge fully paid on or before the due date
    (
        c.amount_paid >= c.amount_due
        AND c.last_payment_date <= c.due_date
    ) AS is_paid_on_time

FROM {{ ref('int_rent_charge_payments') }} AS c
CROSS JOIN as_of AS a
INNER JOIN {{ ref('stg_leases') }} AS l
    ON c.lease_id = l.lease_id