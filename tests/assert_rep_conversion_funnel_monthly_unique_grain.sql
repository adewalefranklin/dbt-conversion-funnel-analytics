select
    month,
    funnel_step,
    count(*) as row_count

from {{ ref('rep_conversion_funnel_monthly') }}

group by
    month,
    funnel_step

having count(*) > 1