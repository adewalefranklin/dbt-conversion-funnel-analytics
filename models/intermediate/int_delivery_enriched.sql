with deliveries_cte as (

    select *
    from {{ ref('stg_delivery') }}

),

subscriptions_cte as (

    select *
    from {{ ref('int_subscription_enriched') }}

),

output_cte as (

    select
        d.delivery_id,
        d.subscription_id,
        d.created_date as delivery_date,
        d.delivery_status,
        d.brand as delivery_brand,
        d.is_deleted as delivery_is_deleted,

        s.lead_id,
        s.patient_account_id,
        s.subscription_status,
        s.start_date as subscription_start_date,
        s.end_date as subscription_end_date,
        s.cancellation_reason,
        s.subscription_brand,

        s.lead_created_date,
        s.lead_status,
        s.is_converted,

        s.account_name,
        s.account_brand

    from deliveries_cte d

    left join subscriptions_cte s
        on d.subscription_id = s.subscription_id

)

select *
from output_cte