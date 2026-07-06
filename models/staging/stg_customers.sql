with source as (
    select *
    from {{ source('raw', 'raw_customers') }}
),

cleaned as (
    select
        trim(customer_id) as customer_id,
        trim(customer_country) as customer_country_raw,
        case
            when upper(trim(customer_country)) in ('UK', 'UNITED KINGDOM') then 'UK'
            when upper(trim(customer_country)) in ('US', 'USA', 'UNITED STATES') then 'US'
            else upper(trim(customer_country))
        end as customer_country,
        date(trim(customer_since_date)) as customer_since_date,
        lower(trim(customer_type)) as customer_type
    from source
),

ranked as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by customer_since_date desc, customer_country_raw
        ) as customer_record_rank
    from cleaned
    where customer_id is not null
      and customer_id <> ''
)

select
    customer_id,
    customer_country_raw,
    customer_country,
    customer_since_date,
    customer_type
from ranked
where customer_record_rank = 1
