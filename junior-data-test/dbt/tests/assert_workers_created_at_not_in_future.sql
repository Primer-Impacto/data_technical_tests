-- EJEMPLO RESUELTO: comprobación de calidad escrita a mano.
-- dbt considera que el test FALLA si esta consulta devuelve alguna fila.
-- Aquí buscamos trabajadores dados de alta con una fecha posterior a hoy,
-- algo que no debería ocurrir y que suele indicar un error de carga.

select
    employee_id,
    created_at
from {{ ref('stg_workers') }}
where created_at > current_date
