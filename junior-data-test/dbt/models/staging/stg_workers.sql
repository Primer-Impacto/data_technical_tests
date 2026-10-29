-- SOLVED EXAMPLE: cleaning the workers table.
-- In Part 2 you will apply the same ideas to visits.

with source as (

    select * from {{ ref('raw_workers') }}

),

cleaned as (

    select
        cast(employee_id as integer)                 as employee_id,
        trim(employee_first_name)                    as employee_first_name,
        upper(trim(employee_active_status)) = 'TRUE' as is_active,

        -- Trim, upper-case and remove accents so "Málaga" and "MALAGA" match,
        -- and keep only the first name of bilingual values ("Valencia/València").
        strip_accents(upper(trim(split_part(employee_address_province, '/', 1)))) as province_raw,

        -- A missing contract type is not guessed: it is flagged as UNKNOWN.
        coalesce(nullif(upper(trim(employee_contract_type)), ''), 'UNKNOWN') as contract_type,

        cast(created_at as date)                     as created_at

    from source

)

select
    employee_id,
    employee_first_name,
    is_active,

    -- Some names arrive reversed ("Coruña, A"), so we put them in their usual order.
    case
        when province_raw = 'CORUNA, A'   then 'A CORUNA'
        when province_raw = 'PALMAS, LAS' then 'LAS PALMAS'
        when province_raw is null or province_raw = '' then 'UNKNOWN'
        else province_raw
    end as province,

    contract_type,
    created_at

from cleaned
