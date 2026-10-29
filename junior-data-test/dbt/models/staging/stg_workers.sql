-- EJEMPLO RESUELTO: limpieza de la tabla de trabajadores.
-- Léelo con calma; en la parte 2 tendrás que aplicar las mismas ideas a las visitas.

with origen as (

    select * from {{ ref('raw_workers') }}

),

limpieza as (

    select
        cast(employee_id as integer)            as employee_id,
        trim(employee_first_name)                as employee_first_name,
        upper(trim(employee_active_status)) = 'TRUE' as is_active,

        -- 1) Quitamos espacios, pasamos a mayúsculas y eliminamos tildes para
        --    que "Málaga" y "MALAGA" se conviertan en el mismo valor.
        -- 2) Nos quedamos con la parte anterior a la barra en los nombres
        --    bilingües: "Valencia/València" pasa a ser "VALENCIA".
        strip_accents(upper(trim(split_part(employee_address_province, '/', 1)))) as provincia_tmp,

        -- Si el tipo de contrato viene vacío no lo inventamos: lo marcamos
        -- explícitamente como DESCONOCIDO para que se vea en los informes.
        coalesce(nullif(upper(trim(employee_contract_type)), ''), 'DESCONOCIDO') as contract_type,

        cast(created_at as date)                 as created_at

    from origen

)

select
    employee_id,
    employee_first_name,
    is_active,

    -- 3) Algunos nombres llegan "dados la vuelta" ("Coruña, A"). Los
    --    reordenamos para que coincidan con la forma habitual.
    case
        when provincia_tmp = 'CORUNA, A'  then 'A CORUNA'
        when provincia_tmp = 'PALMAS, LAS' then 'LAS PALMAS'
        when provincia_tmp is null or provincia_tmp = '' then 'DESCONOCIDA'
        else provincia_tmp
    end as province,

    contract_type,
    created_at

from limpieza
