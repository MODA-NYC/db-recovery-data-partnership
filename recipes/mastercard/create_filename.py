import os
import pandas as pd
from pathlib import Path
import sys

def reduce_csv(csv_name):
    df = pd.read_csv(csv_name, delimiter='|')
    max_date = df['txn_date'].max()
    min_date = df['txn_date'].min()
    #just the filename, not the CSV extension.
    sys.stdout.write(f"mastercard_{min_date}_to_{max_date}" )

if __name__ == "__main__":
    csv_name = sys.argv[1]
    reduce_csv(csv_name)