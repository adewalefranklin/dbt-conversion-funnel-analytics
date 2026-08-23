-- This model answers the question: What happened to each Lead as it progressed into the sales process? (preserves the operational 1:N history of Leads to Opportunities)

with leads_cte as (

    select *
    from {{ ref('stg_lead') }}

),

opportunities as (

    select *
    from {{ ref('stg_opportunity') }}

),

output_cte as (

    select
        o.opportunity_id,
        o.lead_id,
        o.account_id,

        l.created_date as lead_created_date,
        l.status as lead_status,
        l.is_converted,
        l.converted_date,
        l.lead_source,
        l.utm_source,
        l.utm_medium,
        l.utm_campaign,

        o.created_date as opportunity_created_date,
        o.stage_name,
        o.is_closed,
        o.is_won,

        -- keep both brands visible for quality analysis
        l.brand as lead_brand,
        o.brand as opportunity_brand,

        o.owner_id as opportunity_owner_id

    from opportunities o

    left join leads_cte l
        on o.lead_id = l.lead_id

)

select *
from output_cte