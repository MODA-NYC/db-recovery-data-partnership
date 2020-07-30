import sys

sys.path.insert(0, "..")
import pandas as pd
import numpy as np
from _helper.geo import get_hnum, get_sname, get_zipcode, geocode
from multiprocessing import Pool, cpu_count

df1 = pd.read_csv(
    "https://raw.githubusercontent.com/zhik/whats-open-east-village/gh-pages/data/rows.csv",
    dtype=str,
)
df2 = pd.read_csv(
    "https://raw.githubusercontent.com/zhik/whos-open-queens/gh-pages/data/rows.csv",
    dtype=str,
)
df3 = pd.read_csv(
    "https://raw.githubusercontent.com/BetaNYC/open-business-directory/gh-pages/data/rows.csv",
    dtype=str,
)
df4 = pd.read_csv(
    "https://raw.githubusercontent.com/zhik/whos-open-sunnyside/gh-pages/data/rows.csv",
    dtype=str,
)
df5 = pd.read_csv(
    "https://raw.githubusercontent.com/zhik/whos-open-uptowngrandcentral/gh-pages/data/rows.csv",
    dtype=str,
)

cols = [
    "Name",
    "Category",
    "Sub-Category",
    "Phone",
    "Status",
    "Pickup Offered",
    "Delivery Offered",
    "Hours",
    "Special Accommodation Hours",
    "Black Owned Business",
    "MWBE",
    "Source",
    "Last Updated",
    "Latitude",
    "Longitude",
    "Address",
]

df1["Hours"] = df1["Close Time"] + "-" + df1["Open Time"]
df1["Sub-Category"] = df1["Sub Category"]
df3["Black Owned Business"] = ""
df3["MWBE"] = ""

df = pd.concat([df1[cols], df2[cols], df3[cols], df4[cols], df5[cols]])
df.to_csv('input/raw.csv', index=False)

def _geocode(df: pd.DataFrame) -> pd.DataFrame:
    # geocoding
    df = df.fillna('')
    df["hnum"] = df.apply(lambda x: get_hnum(x["Address"]), axis=1)
    df["sname"] = df.apply(lambda x: get_sname(x["Address"]), axis=1)
    df["zipcode"] = df.apply(lambda x: get_zipcode(x["Address"]), axis=1)

    records = df.to_dict("records")
    del df

    # Multiprocess
    with Pool(processes=cpu_count()) as pool:
        it = pool.map(geocode, records, 10000)

    df = pd.DataFrame(it)
    return df

df_geo = _geocode(df)
df_geo.to_csv(sys.stdout, index=False)
