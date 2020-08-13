import pandas as pd
import sys

df = pd.read_excel('input/raw.xlsx', sheet_name='Data')
cols = ['month_begin_date','hiring_rate_sa','mom_change','yoy_change']
for col in cols:
    assert col in df.columns
df.to_csv(sys.stdout, index=False)