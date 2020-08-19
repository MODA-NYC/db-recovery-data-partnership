import sys
import pandas as pd

region_zips = pd.read_csv('../_data/region_zips.csv')

# Read daily data tables from GitHub
df1 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Zearn%20-%20County%20-%20Weekly.csv",
    dtype=str,
    na_values='.'
)
df2 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/UI%20Claims%20-%20County%20-%20Weekly.csv",
    dtype=str,
    na_values='.'
)

# Filter to NYC and set FIPS code as index
dfs = [df1, df2]
dfs = [df[df.countyfips.isin(region_zips.county_fip.tolist())].set_index(["countyfips","year","month","day_endofweek"], drop=True) for df in dfs]

# Concatenate tables and reset index
merged = pd.concat(dfs, axis=1, join='outer', copy=False)
merged.reset_index(drop=False, inplace=True)

merged.to_csv('input/weekly_raw.csv', index=False)
merged.to_csv(sys.stdout, index=False)