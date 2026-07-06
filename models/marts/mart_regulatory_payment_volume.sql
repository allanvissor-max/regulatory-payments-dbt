with reporting_period as (
    select *
    from {{ ref('fct_payments') }}
    where transaction_date >= date('2022-04-01')
      and transaction_date < date('2023-08-01')
),

classified as (
    select
        *,
        case
            when customer_country = 'UK'
             and is_cross_currency = 1
             and route_involves_gbp = 1
                then 'R1_UK_cross_currency_GBP_route'
            when customer_country = 'US'
             and is_cross_currency = 1
                then 'R2_US_cross_currency'
            when customer_country = 'US'
             and is_same_currency = 1
                then 'R2_US_same_currency'
        end as reporting_requirement
    from reporting_period
)

select
    reporting_requirement,
    customer_country,
    strftime('%Y-%m-01', transaction_date) as transaction_month,
    count(*) as transaction_count,
    round(sum(volume_gbp), 2) as total_volume_gbp,
    round(avg(volume_gbp), 2) as average_transaction_volume_gbp
from classified
where reporting_requirement is not null
group by 1, 2, 3
