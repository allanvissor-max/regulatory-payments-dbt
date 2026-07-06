select *
from {{ ref('mart_regulatory_payment_volume') }}
where reporting_requirement not in (
    'R1_UK_cross_currency_GBP_route',
    'R2_US_cross_currency',
    'R2_US_same_currency'
)
