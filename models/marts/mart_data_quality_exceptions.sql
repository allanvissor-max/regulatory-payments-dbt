with records as (
    select *
    from {{ ref('int_payment_enriched') }}
)

select
    raw_row_id,
    transaction_id,
    customer_id,
    transaction_date,
    currency_route,
    amount_gbp,
    trim(
        case when transaction_id is null or transaction_id = '' then 'missing transaction ID; ' else '' end ||
        case when transaction_record_rank > 1 then 'duplicate transaction ID; ' else '' end ||
        case when transaction_date is null then 'invalid transaction date; ' else '' end ||
        case when amount_gbp is null then 'missing or non-numeric amount; ' else '' end ||
        case when has_valid_currency_route = 0 then 'invalid currency route; ' else '' end ||
        case when has_valid_customer = 0 then 'orphan customer; ' else '' end ||
        case when has_valid_customer = 1 and customer_since_date > transaction_date then 'transaction before customer onboarding; ' else '' end
    ) as exception_reason
from records
where is_valid_record = 0
