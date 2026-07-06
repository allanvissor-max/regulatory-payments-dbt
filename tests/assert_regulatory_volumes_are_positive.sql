select *
from {{ ref('mart_regulatory_payment_volume') }}
where total_volume_gbp < 0
