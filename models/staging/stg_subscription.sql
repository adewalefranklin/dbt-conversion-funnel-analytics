with source_cte as (

    select *
    from {{ source('assignment', 'SUBSCRIPTION__C') }}

),

cleaned_cte as (

    select
        id,
        is_deleted,
        created_date,
        last_modified_date,

        status__c,
        brand__c,
        patient__c,
        lead__c,
        approval__c,
        delivery_cycle__c,

        try_cast(
            nullif(trim(start_date__c), '')
            as date
        ) as start_date,

        try_cast(
            nullif(trim(end_date__c), '')
            as date
        ) as end_date,

        nullif(trim(cancellation_reason__c), '') as cancellation_reason,

        owner_id

    from source_cte

),

output_cte as (

    select
        id as subscription_id,
        is_deleted,
        created_date,
        last_modified_date,

        status__c as subscription_status,
        brand__c as brand,

        patient__c as patient_account_id,
        lead__c as lead_id,
        approval__c as approval_id,

        delivery_cycle__c as delivery_cycle,

        start_date,
        end_date,
        cancellation_reason,

        owner_id

    from cleaned_cte

)

select *
from output_cte