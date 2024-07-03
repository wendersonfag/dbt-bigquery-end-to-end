-- models/staging/stg_orders.sql

/*with source_2023 as (
    select * from {{ source('ecom', 'raw_orders_2023') }}
),

source_2024 as (
    select * from {{ source('ecom', 'raw_orders_2024') }}
),

combined_sources as (
    select * from source_2023
    union all
    select * from source_2024
),*/

WITH source AS (
--usando a macro.union_relations para combinar as tabela raw
    {{ dbt_utils.union_relations(
        relations=[
            source('ecom', 'raw_orders_2023'),
            source('ecom', 'raw_orders_2024')
        ]
    ) }}
),

renamed AS (

    SELECT

        ----------  ids
        id AS order_id,
        store_id AS location_id,
        customer AS customer_id,

        ---------- numerics









        subtotal AS subtotal_cents,
        tax_paid AS tax_paid_cents,
        order_total AS order_total_cents,
        -- Substituição manual do cents_to_dollars
        {{ cents_to_dollars('subtotal') }} AS subtotal,
        -- Substituição manual do cents_to_dollars
        {{ cents_to_dollars('tax_paid') }}  AS tax_paid,
        -- Substituição manual do cents_to_dollars
        {{ cents_to_dollars('order_total') }} AS order_total,

        ---------- timestamps
        -- Substituição manual do dbt.date_trunc
        date_trunc(ordered_at, DAY) AS ordered_at

    FROM source

)

SELECT * FROM renamed
