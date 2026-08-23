with source_cte as (

    select *
    from {{ source('assignment', 'OPPORTUNITY') }}

),

cleaned_cte as (

    select
        id,
        is_deleted,
        account_id,

        -- keep the original value for traceability
        stage_name as stage_name_raw,

        -- normalize case and repeated / surrounding whitespace
        lower(
            regexp_replace(
                trim(stage_name), -- Regex was used to remove leading/trailing whitespace and spaces in between words that were discovered during Data Exploration and Quality Checks.
                '\s+',
                ' ',
                'g'
            )
        ) as normalized_stage_name,

        is_closed,
        is_won,
        created_date,
        last_modified_date,
        last_stage_change_date,
        lead__c,
        brand__c,
        owner_id

    from source_cte

),

output_cte as (

    select
        id as opportunity_id,
        is_deleted,
        account_id,

        stage_name_raw,

        case
            when normalized_stage_name = 'closed won'
                then 'Closed Won'
            when normalized_stage_name = 'closed lost'
                then 'Closed Lost'
            when normalized_stage_name = 'ist beantragt'
                then 'Ist Beantragt'
            when normalized_stage_name = 'wird unterschrieben'
                then 'Wird Unterschrieben'
            when normalized_stage_name = 'zu beraten'
                then 'Zu Beraten'
            when normalized_stage_name = 'zu korrigieren'
                then 'Zu Korrigieren'
            else normalized_stage_name
        end as stage_name,

        is_closed,
        is_won,
        created_date,
        last_modified_date,
        last_stage_change_date,

        lead__c as lead_id,
        brand__c as brand,
        owner_id

    from cleaned_cte

)

select *
from output_cte