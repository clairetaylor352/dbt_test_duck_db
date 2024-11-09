WITH activity_with_customer_info AS (
    SELECT
        activity.*,
        customers.customer_country,
        acq_orders.taxonomy_business_category_group
    FROM {{ ref('activity') }} AS activity
    INNER JOIN {{ ref('customers') }} AS customers
        ON activity.customer_id = customers.customer_id
    INNER JOIN {{ ref('acq_orders') }} AS acq_orders
        ON activity.customer_id = acq_orders.customer_id

),

activity_dates AS (
    SELECT
        *,
        coalesce(min(from_date) OVER (PARTITION BY customer_id) = from_date,
        FALSE) AS is_customer_first_registration_date,
        coalesce(min(from_date) OVER (PARTITION BY subscription_id) = from_date,
        FALSE) AS is_subscription_first_registration_date,
        coalesce(max(to_date) OVER (PARTITION BY customer_id) = to_date,
        FALSE) AS is_customer_last_deregistration_date,
        coalesce(min(to_date) OVER (PARTITION BY subscription_id) = to_date,
        FALSE) AS is_subscription_last_deregistration_date
    FROM activity_with_customer_info

)

SELECT * FROM activity_dates
