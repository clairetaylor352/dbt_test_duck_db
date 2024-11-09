# Analyse subscriptions in duckdb

## The Data
### customers

Columns

`customer_id` - unique, not null

`customer_country` - country of customer, not null

This table is unique by customers, each customer has only one country

### acq_orders

Columns

`customer_id` - unique, not null

`taxonomy_business_category_group` - category of subscription, not null

Note this table is also unique by customer_id, so each customer only currently has one of these categories. We will model assuming this is the case, though noting that it seems possible that in the future a customer could have more than one.

### activity

Columns

`customer_id` - links to customer_id from customers, not null

`subscription_id` - id for subscription. Note that one customer can have multiple subscriptions, and that a subscription can have multiple activity rows. However a subscription cannot belong to more than customer

`from_date` - start date of activity - date not null

`to_date` - end date of activity - date not null


I note this table always has a `to_date` meaning that if we are using this table to figure out if a customer or subscription is active, they are always going to eventually be inactive. This means that the resulting table below always drops all the users down to inactive on the final month. 

## What this analysis produces

For the purposes of simplicity, we deal with registering customers and no longer active customers by month, customer_country and taxonomy group.

If we wanted the same data for subscriptions, we could produce similar analysis.

Other limitations to note: A customer is counted as still active in this table even if they don't have a subscription "activity" for that month. If this is an incorrect assumption, we can change it.

The table has entries for all months from Jan 2019 to the present, for all country and taxonomy combinations, even if there were no active customers that month (or registering customers)

Table

`customer_acquisition_monthly`

Columns

`first_day_of_month` - first day of the month in question

`month_of_year` - number of the month, from 1 (January) to 12 (December)

`month_name` - name of month

`year_key` - year, 4 digits, eg 2020

`customer_country` - country of the customer

`taxonomy_business_category_group` - category of the customer's subscription(s)

`registering_customer_count` - count of distinct customers for this country and category who have their first ever activity in this month

`deregistering_customer_count` - count of distinct customers for this coutnry and category who have their last ever activity in this month

`active_customer_count` - count of customers who have had their first ever activity in or before this month, and for which their last ever activity is either this month or in future months

`churn_rate` - proportion of customers who deregistered in a month as a proportion of that months active customers. If there are no active customers, this will be `nan`

Note: If you wish to use this table to aggregate up (e.g. to find stats for a country but over all taxonomy categories) then that will work and you can just sum the customer count fields as appropriate. However, you cannot do the same with `churn` - this field needs to be recalculated on the aggregated counts.

## How to look at the results

### I am feeling lazy
Take a look at `output/customer_acquisition_monthly.csv`

The principal logic in this repo is contained in `fact_activity.sql` and `customer_activity_monthly.sql`. It also contains a data table, `dim_date.sql` (which is copied off the internet..)

### I want to have a look around

1. Start up codespaces from this repo
2. Run `./scripts/linux_setup.sh` in the terminal
3. Run `dbt build` - this will read in the data into a duckdb instance and output the csv that is saved to this repo
4. Run `./duckdb test_duckdb.duckdb` - you can then have a look around the tables created by dbt

If you start up the codespace subsequently, you do not need to rerun the set up script above, but you will need to run `source .venv/bin/activate` to activate the virtual environment with dbt in it.


