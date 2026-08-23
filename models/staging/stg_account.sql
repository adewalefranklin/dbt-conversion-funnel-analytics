with source_cte as (

    select *
    from {{ source('assignment', 'ACCOUNT') }}

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
        id as account_id,
        is_deleted,
        name as account_name,
        created_date,
        brand__c as brand,
        owner_id
    from deduplicated
    where row_num = 1

)

select *
from output_cte