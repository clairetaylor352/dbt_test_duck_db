{{ config(materialized='external', location='output/customer_acquistion_monthly.csv') }}

SELECT * FROM {{ ref('customer_acquisition_monthly') }}