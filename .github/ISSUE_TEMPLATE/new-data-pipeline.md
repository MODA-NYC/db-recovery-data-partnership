---
name: New data pipeline
about: This issue documents the creation of a new dataset.
title: <Partner>/<subproduct>/latest/<file name>.csv
labels: ''
assignees: ''

---
## Output: `<Partner>/<subproduct>/latest/<file name>.csv`
> this is the final file path of the table in sharepoint. e.g. `cuebiq/cuebiq_mobility/latest/cuebiq_daily_mobility.csv`, if there's only one data product under the data partnership, you can ignore the subproduct path, e.g. `linkedin/latest/linkedin_nyc_hiringrate.csv`

## Update Cycle: 
> Please provide how often this table should be generated (daily, weekly, or manual?)

## Description
a brief description of the table, must include the following info: time interval (e.g. monthly, weekly), geographic level (e.g. borough, NYC, nta)

## Schema Mapping:
> Note: find naming convention [here](https://github.com/MODA-NYC/db-recovery-data-partnership/wiki/New-data-pipeline:-field-naming-convention)

| Input field name | Data Type   | Output field name | Output example |
|------------------|-------------|-------------------|----------------|
| source field name | `text`,`numeric`,`date`,`timestamp` | RDP field name | example |
| e.g. reference_date     | `date` | date         | 2020-06-20     |
| e.g. date     | `text` | year_week         | 2020-45    |
| e.g. county_code    | `text` | fips_county |   36001   |
| e.g. county_name     | `text` | county | Albany |
| e.g. last_14_days_travelers     | `int` | last_14_days_travelers |    141  |
