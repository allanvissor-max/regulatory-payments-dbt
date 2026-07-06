select
    transaction_id,
    customer_id,
    customer_country,
    customer_type,
    transaction_date,
    currency_route,
    from_currency,
    to_currency,
    is_cross_currency,
    is_same_currency,
    route_involves_gbp,
    amount_gbp as signed_amount_gbp,
    abs(amount_gbp) as volume_gbp
from {{ ref('int_payment_enriched') }}
where is_valid_record = 1
