import os
from os import getcwd, path
import pandas as pd
import sys
from pathlib import Path

df = pd.read_excel(os.path.join(os.getcwd(), 'input', 'raw.xlsx'), 1)
print(df.info())
cols = ['month_begin_date','hiring_rate_sa','mom_change','yoy_change']
for col in cols:
    assert col in df.columns
df.to_csv(sys.stdout, index=False)