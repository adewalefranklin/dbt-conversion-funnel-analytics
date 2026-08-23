with leads_cte as (

    select *
    from {{ ref('stg_lead') }}

),

opportunity_summary as (

    select
        lead_id,
        count(*) as opportunity_count,

        max(
            case
                when stage_name = 'Closed Won' then 1
                else 0
            end
        ) as has_won_opportunity

    from {{ ref('int_lead_opportunity') }}
    where lead_id is not null
    group by lead_id

),

subscription_summary as (

    select
        lead_id,
        count(*) as subscription_count,

        max(
            case
                when subscription_status = 'Active' then 1
                else 0
            end
        ) as has_active_subscription

    from {{ ref('int_subscription_enriched') }}
    where lead_id is not null
    group by lead_id

),

delivery_summary as (

    select
        lead_id,
        count(*) as delivery_count,

        case
            when count(*) > 0 then 1
            else 0
        end as has_first_delivery,

        max(
            case
                when delivery_status = 'Delivered' then 1
                else 0
            end
        ) as has_successful_delivery

    from {{ ref('int_delivery_enriched') }}
    where lead_id is not null
    group by lead_id

),

output_cte as (

    select
        l.lead_id,
        l.created_date as lead_created_date,
        l.status as lead_status,

        case
            when l.status = 'Qualified' then 1
            else 0
        end as is_qualified,

        case
            when l.is_converted then 1
            else 0
        end as is_converted,

        l.converted_date,
        l.lead_source,
        l.brand as lead_brand,
        l.utm_source,
        l.utm_medium,
        l.utm_campaign,

        coalesce(o.opportunity_count, 0) as opportunity_count,
        coalesce(o.has_won_opportunity, 0) as has_won_opportunity,

        coalesce(s.subscription_count, 0) as subscription_count,
        coalesce(s.has_active_subscription, 0) as has_active_subscription,

        coalesce(d.delivery_count, 0) as delivery_count,
        coalesce(d.has_first_delivery, 0) as has_first_delivery,
        coalesce(d.has_successful_delivery, 0) as has_successful_delivery

    from leads_cte l

    left join opportunity_summary o
        on l.lead_id = o.lead_id

    left join subscription_summary s
        on l.lead_id = s.lead_id

    left join delivery_summary d
        on l.lead_id = d.lead_id

)

select *
from output_cte