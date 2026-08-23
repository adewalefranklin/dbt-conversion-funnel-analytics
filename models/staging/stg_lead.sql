with source_cte as (

    select *
    from {{ source('assignment', 'LEAD') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by id
            order by created_date asc
        ) as row_num

    from source_cte

),

output_cte as (

    select
        id as lead_id,
        is_deleted,
        first_name,
        last_name,
        lead_source,
        status,
        substatus__c as substatus,
        is_converted,
        converted_date,
        converted_account_id,
        converted_opportunity_id,
        created_date,
        last_modified_date,
        brand__c as brand,
        utm_source__c as utm_source,
        utm_medium__c as utm_medium,
        utm_campaign__c as utm_campaign,
        owner_id

    from deduplicated
    where row_num = 1

)

select *
from output_cte