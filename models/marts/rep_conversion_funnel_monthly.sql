with funnel_cte as (

    select *
    from {{ ref('int_lead_funnel') }}

),

monthly_counts as (

    select
        cast(date_trunc('month', lead_created_date) as date) as month,

        count(*) as lead_created,

        sum(
            case
                when is_qualified = 1
                then 1
                else 0
            end
        ) as lead_qualified,

        sum(
            case
                when is_qualified = 1
                 and is_converted = 1
                then 1
                else 0
            end
        ) as lead_converted,

        sum(
            case
                when is_qualified = 1
                 and is_converted = 1
                 and has_won_opportunity = 1
                then 1
                else 0
            end
        ) as opportunity_won,

        sum(
            case
                when is_qualified = 1
                 and is_converted = 1
                 and has_won_opportunity = 1
                 and has_active_subscription = 1
                then 1
                else 0
            end
        ) as subscription_active,

        sum(
            case
                when is_qualified = 1
                 and is_converted = 1
                 and has_won_opportunity = 1
                 and has_active_subscription = 1
                 and has_first_delivery = 1
                then 1
                else 0
            end
        ) as first_delivery

    from funnel_cte

    group by 1

),

funnel_long as (

    select
        month,
        'Lead Created' as kpi_name,
        1 as funnel_step,
        lead_created as count
    from monthly_counts

    union all

    select
        month,
        'Lead Qualified' as kpi_name,
        2 as funnel_step,
        lead_qualified as count
    from monthly_counts

    union all

    select
        month,
        'Lead Converted' as kpi_name,
        3 as funnel_step,
        lead_converted as count
    from monthly_counts

    union all

    select
        month,
        'Opportunity Won' as kpi_name,
        4 as funnel_step,
        opportunity_won as count
    from monthly_counts

    union all

    select
        month,
        'Subscription Active' as kpi_name,
        5 as funnel_step,
        subscription_active as count
    from monthly_counts

    union all

    select
        month,
        'First Delivery' as kpi_name,
        6 as funnel_step,
        first_delivery as count
    from monthly_counts

),

with_previous_step as (

    select
        month,
        kpi_name,
        funnel_step,
        count,

        lag(count) over (
            partition by month
            order by funnel_step
        ) as previous_step_count

    from funnel_long

),

output_cte as (

    select
        month,
        kpi_name,
        funnel_step,
        count,

        case
            when funnel_step = 1 then null

            when previous_step_count = 0 then null

            else round(
                count * 100.0 / previous_step_count,
                2
            )
        end as conversion_from_previous_pct

    from with_previous_step

)

select *
from output_cte

order by
    month,
    funnel_step