with funnel as (

    select
        month,
        funnel_step,
        count,

        lag(count) over (
            partition by month
            order by funnel_step
        ) as previous_step_count

    from {{ ref('rep_conversion_funnel_monthly') }}

)

select
    month,
    funnel_step,
    count,
    previous_step_count

from funnel

where funnel_step > 1
  and count > previous_step_count