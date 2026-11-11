SELECT
    customer_id,
    full_name,
    email AS hashed_email,
    country,
    _fivetran_synced
FROM {{ source('omnistyle_prod', 'customers') }}
WHERE COALESCE(_fivetran_deleted, FALSE) = FALSE
