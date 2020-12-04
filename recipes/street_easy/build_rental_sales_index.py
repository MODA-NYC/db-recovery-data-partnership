import os
import sys
import pandas as pd

# Dowload source data from s3
url_rent_index = "https://streeteasy-market-data-download.s3.amazonaws.com/rentals/All/rentalIndex_All.zip"
url_sales_index = "https://streeteasy-market-data-download.s3.amazonaws.com/sales/All/priceIndex_All.zip"

rent_index = pd.read_csv(
    url_rent_index, dtype=str, compression="zip", index_col="Month"
)
sales_index = pd.read_csv(
    url_sales_index, dtype=str, compression="zip", index_col="Month"
)

# Unpivotting tables
r = (
    rent_index[["Brooklyn", "Manhattan", "NYC", "Queens"]]
    .stack()
    .reset_index()
    .rename(columns={"level_1": "borough", 0: "rental_index"})
)

s = (
    sales_index[["Brooklyn", "Manhattan", "NYC", "Queens"]]
    .stack()
    .reset_index()
    .rename(columns={"level_1": "borough", 0: "sales_index"})
)

df = s.merge(r, on=["Month", "borough"], how="outer")
df.to_csv(
    sys.stdout, index=False, columns=["Month", "borough", "sales_index", "rental_index"]
)
