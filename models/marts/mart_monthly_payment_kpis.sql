select
    strftime('%Y-%m-01', transaction_date) as transaction_month,
    customer_country,
    count(*) as transaction_count,
    sum(is_cross_currency) as cross_currency_transaction_count,
    sum(is_same_currency) as same_currency_transaction_count,
    round(sum(volume_gbp), 2) as total_volume_gbp,
    round(avg(volume_gbp), 2) as average_transaction_volume_gbp
from {{ ref('fct_payments') }}
group by 1, 2
