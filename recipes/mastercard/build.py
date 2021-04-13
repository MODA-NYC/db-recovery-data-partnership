import pandas as pd
from pathlib import Path
import glob
import os

CWD = Path.cwd()

#find the file name


filepaths = glob.glob('/input/*.csv')
'''
print(filepaths[0])
print("type filepaths: {}".format(type(filepaths[0])))
print("len filepaths: {}".format(len(filepaths[0])))
'''
'''if filepaths is not None:
    print(type(filepaths))
else:
    raise Exception("could not find Mastercard extracted csv in input directory.")
'''
print('reading Mastercard CSV')
df = pd.read_csv(Path(filepaths[0]), sep='|')
df.head()
