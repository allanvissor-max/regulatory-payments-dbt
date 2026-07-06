with source as (
    select *
    from {{ source('raw', 'raw_transactions') }}
),

cleaned as (
    select
        raw_row_id,
        trim(transaction_id) as transaction_id,
        trim(customer_id) as customer_id,
        date(trim(transaction_date)) as transaction_date,
        upper(trim(currency_route)) as currency_route,
        case
            when trim(amount_gbp) is null or trim(amount_gbp) = '' then null
            else cast(trim(amount_gbp) as real)
        end as amount_gbp
    from source
),

parsed as (
    select
        *,
        case
            when instr(currency_route, '-->') > 0
                then trim(substr(currency_route, 1, instr(currency_route, '-->') - 1))
        end as from_currency,
        case
            when instr(currency_route, '-->') > 0
                then trim(substr(currency_route, instr(currency_route, '-->') + 3))
        end as to_currency
    from cleaned
),

ranked as (
    select
        *,
        row_number() over (
            partition by transaction_id
            order by raw_row_id
        ) as transaction_record_rank
    from parsed
)

select
    raw_row_id,
    transaction_id,
    customer_id,
    transaction_date,
    currency_route,
    from_currency,
    to_currency,
    amount_gbp,
    transaction_record_rank,
    case
        when from_currency is not null
         and to_currency is not null
         and length(from_currency) = 3
         and length(to_currency) = 3
        then 1 else 0
    end as has_valid_currency_route
from ranked
