from os.path import exists
import pandas as pd
import sys

if exists('input/raw.xlsx'):
    print("raw.xlsx in fact exists")
else:
    raise Exception("'raw.xlsx' does not exist!")
df = pd.read_excel(open('input/raw.xlsx', 'rb'), sheetname='Data')
cols = ['month_begin_date','hiring_rate_sa','mom_change','yoy_change']
for col in cols:
    assert col in df.columns
df.to_csv(sys.stdout, index=False)