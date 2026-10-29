-- SOLVED EXAMPLE: a hand-written test.
-- dbt marks the test as FAILED if this query returns any rows.
-- A worker created after today usually points to a loading error.

select
    employee_id,
    created_at
from {{ ref('stg_workers') }}
where created_at > current_date
