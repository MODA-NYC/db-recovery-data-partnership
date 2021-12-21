import pandas as pd
import sys

df = pd.read_csv('input/raw.csv')
cols = ['month_begin_date','hiring_rate_sa','mom_change','yoy_change']
for col in cols:
    assert col in df.columns
df.to_csv(sys.stdout, index=False)