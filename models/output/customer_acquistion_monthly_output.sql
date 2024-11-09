{{ config(materialized='external', location='output/customer_acquisition_monthly.csv') }}

SELECT * FROM {{ ref('customer_acquisition_monthly') }}