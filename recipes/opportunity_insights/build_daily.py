import sys
import pandas as pd

NYC_FIPS = ['36005','36047','36061','36081','36085']

# Read daily data tables from GitHub
df1 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Affinity%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df2 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/COVID%20Cases%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df3 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/COVID%20Deaths%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df4 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Google%20Mobility%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df5 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Womply%20Merchants%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)
df6 = pd.read_csv(
    "https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Womply%20Revenue%20-%20County%20-%20Daily.csv",
    dtype=str,
    na_values='.'
)

# Filter to NYC and set FIPS code as index
dfs = [df1, df2, df3, df4, df5, df6]
dfs = [df[df.countyfips.isin(NYC_FIPS)].set_index(["countyfips","year","month","day"], drop=True) for df in dfs]
for df in dfs:
    print(list(df))
    print(df.head())

# Concatenate tables and reset index
merged = pd.concat(dfs, axis=1, join='outer', copy=False)
merged.reset_index(drop=False, inplace=True)

merged.to_csv('input/daily_raw.csv', index=False)
merged.to_csv(sys.stdout, sep='|', index=False)