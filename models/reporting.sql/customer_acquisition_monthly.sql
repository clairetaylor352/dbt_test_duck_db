WITH category_country AS (
    SELECT
        customer_country,
        taxonomy_business_category_group
    FROM {{ ref('fact_activity') }}
    GROUP BY customer_country, taxonomy_business_category_group
),

dim_date_with_category_country AS (
    SELECT
        dim_date.*,
        category_country.*
    FROM {{ ref('dim_date') }} AS dim_date
    FULL OUTER JOIN category_country
        ON 1 = 1
),


registering_customers AS (
    SELECT
        dim_date.first_day_of_month,
        dim_date.month_of_year,
        dim_date.month_name,
        dim_date.year_key,
        dim_date.customer_country,
        dim_date.taxonomy_business_category_group,
        COALESCE(COUNT(DISTINCT activity.customer_id), 0) AS registering_customers_count

    FROM
        dim_date_with_category_country AS dim_date
    LEFT JOIN {{ ref('fact_activity') }} AS activity
        ON
            dim_date.date_key = activity.from_date
            AND dim_date.customer_country = activity.customer_country
            AND dim_date.taxonomy_business_category_group
            = activity.taxonomy_business_category_group
            AND activity.is_customer_first_registration_date
    GROUP BY
        dim_date.month_of_year,
        dim_date.first_day_of_month,
        dim_date.year_key,
        dim_date.month_name,
        dim_date.customer_country,
        dim_date.taxonomy_business_category_group

),

deregistering_customers AS (
    SELECT
        dim_date.first_day_of_month,
        dim_date.month_of_year,
        dim_date.month_name,
        dim_date.year_key,
        dim_date.customer_country,
        dim_date.taxonomy_business_category_group,
        COALESCE(COUNT(DISTINCT activity.customer_id), 0)
            AS deregistering_customers_count
    FROM
        dim_date_with_category_country AS dim_date
    LEFT JOIN {{ ref('fact_activity') }} AS activity
        ON
            dim_date.date_key = activity.to_date
            AND dim_date.customer_country = activity.customer_country
            AND dim_date.taxonomy_business_category_group
            = activity.taxonomy_business_category_group
            AND activity.is_customer_last_deregistration_date
    GROUP BY
        dim_date.first_day_of_month,
        dim_date.month_of_year,
        dim_date.year_key,
        dim_date.month_name,
        dim_date.customer_country,
        dim_date.taxonomy_business_category_group

),

register_and_deregister AS (
    SELECT
        register.first_day_of_month,
        register.month_of_year,
        register.month_name,
        register.year_key,
        register.customer_country,
        register.taxonomy_business_category_group,
        register.registering_customers_count,
        deregister.deregistering_customers_count,
        SUM(
            register.registering_customers_count
            - deregister.deregistering_customers_count
        ) OVER (PARTITION BY
            register.customer_country,
            register.taxonomy_business_category_group
        ORDER BY register.year_key, register.month_of_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS previous_active_customer_count,
        COALESCE(previous_active_customer_count, 0)
        + register.registering_customers_count AS active_customers_count,
        deregister.deregistering_customers_count / active_customers_count AS churn_rate
    FROM registering_customers AS register
    INNER JOIN deregistering_customers AS deregister
        ON
            register.first_day_of_month = deregister.first_day_of_month
            AND register.customer_country = deregister.customer_country
            AND register.taxonomy_business_category_group
            = deregister.taxonomy_business_category_group
)

SELECT * FROM register_and_deregister
