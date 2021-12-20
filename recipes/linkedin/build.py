import os
from os import getcwd, path
import pandas as pd
import sys
from pathlib import Path

raw_xl_path = os.path.join(os.getcwd(), 'input', 'raw.xlsx')
#if raw_xl_path.is_file():
#    print("'raw.xlsx does in fact exist.")
#else:
#    raise Exception("raw.xlsx not found!")
#df = pd.read_excel(raw_xl_path), 0)
xlsx = pd.ExcelFile(raw_xl_path)
df = pd.read_excel(xlsx, 'Data')
print(df.info())
cols = ['month_begin_date','hiring_rate_sa','mom_change','yoy_change']
for col in cols:
    assert col in df.columns
df.to_csv(sys.stdout, index=False)