import sys
import pandas as pd

region = pd.read_csv('../_data/countyfips_region.csv')

# Read daily data tables from GitHub
df1 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Affinity%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df2 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Google%20Mobility%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df3 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Womply%20Merchants%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df4 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Womply%20Revenue%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)


# Filter to NYC region and set FIPS code as index
dfs = [df1, df2, df3, df4]
counties = region.county_fip.astype(str).tolist()
dfs = [df[df.countyfips.isin(counties)].set_index(["countyfips","year","month","day"], drop=True) for df in dfs]

# Concatenate tables and reset index
merged = pd.concat(dfs, axis=1, join='outer', copy=False)
merged.reset_index(drop=False, inplace=True)

merged.to_csv('input/daily_raw.csv', index=False)
merged.to_csv(sys.stdout, sep='|', index=False)