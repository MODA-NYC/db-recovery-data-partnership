import os
import sys
import pandas as pd

url = os.environ.get('URL_STREET_EASY')

# Read input data
cols = [
        "nta_name",
        "nta_code",
        "no._of_new_sale_listings",
        "no._of_pending_sale_listings",
        "no._of_sale_listings",
        "pct_hike_(sales)",
        "pct_cut_(sales)",
        "median_weeks_on_market_(sales)",
        "no._of_new_rental_listings",
        "no._of_pending_rental_listings",
        "no._of_rental_listings",
        "pct_hike_(rentals)",
        "pct_cut_(rentals)",
        "pct_furnished_(rentals)",
        "pct_short_term_(rentals)",
        "pct_with_concessions_(rentals)",
        "median_weeks_on_market_(rentals)",
        "week_start_date",
        "week_end_date"
    ]

df = pd.read_csv(f"{url}/nta/nta-metrics-2020-06-01.csv")

df.columns = [i.lower().replace(" ", "_") for i in df.columns]
for col in cols:
    try:
        assert col in df.columns
    except AssertionError as error:
        print(f'{col} is missing')

for col in ["no._of_new_sale_listings",
            "no._of_pending_sale_listings",
            "no._of_sale_listings",
            "no._of_new_rental_listings",
            "no._of_pending_rental_listings",
            "no._of_rental_listings"]:
    df[col] = df[col].fillna(0).astype(int)
    
df[cols].to_csv(sys.stdout, sep='|', index=False)