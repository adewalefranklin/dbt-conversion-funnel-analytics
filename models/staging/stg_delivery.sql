   with source_cte as (

    select *
    from {{ source('assignment', 'DELIVERY__C') }}

),

output_cte as (

    select
        id as delivery_id,
        is_deleted,
        created_date,
        subscription__c as subscription_id,
        brand__c as brand,
        status__c as delivery_status

    from source_cte

)

select *
from output_cte