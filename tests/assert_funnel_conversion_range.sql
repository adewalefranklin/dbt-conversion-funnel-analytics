select *
from {{ ref('rep_conversion_funnel_monthly') }}

where
    (
        funnel_step = 1
        and conversion_from_previous_pct is not null
    )

    or

    (
        funnel_step > 1
        and conversion_from_previous_pct is not null
        and (
            conversion_from_previous_pct < 0
            or conversion_from_previous_pct > 100
        )
    )