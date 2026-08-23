with subscriptions_cte as (

    select *
    from {{ ref('stg_subscription') }}

),

leads_cte as (

    select *
    from {{ ref('stg_lead') }}

),

accounts_cte as (

    select *
    from {{ ref('stg_account') }}

),

output_cte as (

    select
        s.subscription_id,
        s.lead_id,
        s.patient_account_id,

        s.subscription_status,
        s.delivery_cycle,
        s.start_date,
        s.end_date,
        s.cancellation_reason,
        s.brand as subscription_brand,
        s.approval_id,
        s.created_date as subscription_created_date,
        s.last_modified_date as subscription_last_modified_date,
        s.is_deleted as subscription_is_deleted,

        l.status as lead_status,
        l.is_converted,
        l.created_date as lead_created_date,
        l.brand as lead_brand,

        a.account_name,
        a.created_date as account_created_date,
        a.brand as account_brand

    from subscriptions_cte s

    left join leads_cte l
        on s.lead_id = l.lead_id

    left join accounts_cte a
        on s.patient_account_id = a.account_id

)

select *
from output_cte