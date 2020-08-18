import sys
import pandas as pd

NYC_FIPS = ['36005','36047','36061','36081','36085']

# Read daily data tables from GitHub
df1 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Zearn%20-%20County%20-%20Weekly.csv",
    dtype=str,
)
df2 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/UI%20Claims%20-%20County%20-%20Weekly.csv",
    dtype=str,
)

# Filter to NYC and set FIPS code as index
dfs = [df1, df2]
dfs = [df[df.countyfips.isin(NYC_FIPS)].set_index(["countyfips","year","month","day_endofweek"], drop=True) for df in dfs]

# Concatenate tables and reset index
merged = pd.concat(dfs, axis=1, join='outer', copy=False)
merged.reset_index(drop=False, inplace=True)

merged.to_csv('input/weekly_raw.csv', index=False)
merged.to_csv(sys.stdout, index=False)