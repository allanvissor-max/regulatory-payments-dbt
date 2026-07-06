with transactions as (
    select *
    from {{ ref('stg_transactions') }}
),

customers as (
    select *
    from {{ ref('stg_customers') }}
),

joined as (
    select
        t.raw_row_id,
        t.transaction_id,
        t.customer_id,
        t.transaction_date,
        t.currency_route,
        t.from_currency,
        t.to_currency,
        t.amount_gbp,
        t.transaction_record_rank,
        t.has_valid_currency_route,
        c.customer_country,
        c.customer_type,
        c.customer_since_date,
        case when c.customer_id is not null then 1 else 0 end as has_valid_customer,
        case when t.from_currency <> t.to_currency then 1 else 0 end as is_cross_currency,
        case when t.from_currency = t.to_currency then 1 else 0 end as is_same_currency,
        case when t.from_currency = 'GBP' or t.to_currency = 'GBP' then 1 else 0 end as route_involves_gbp
    from transactions t
    left join customers c
        on t.customer_id = c.customer_id
)

select
    *,
    case
        when transaction_id is not null
         and transaction_id <> ''
         and transaction_record_rank = 1
         and transaction_date is not null
         and amount_gbp is not null
         and has_valid_currency_route = 1
         and has_valid_customer = 1
         and customer_since_date <= transaction_date
        then 1 else 0
    end as is_valid_record
from joined
