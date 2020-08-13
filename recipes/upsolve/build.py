import sys
import os
import pandas as pd
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import json

def get_data() -> pd.DataFrame:
    GSHEET_UPSOLVE=os.environ.get('GSHEET_UPSOLVE')

    scope = ['https://spreadsheets.google.com/feeds']
    creds = ServiceAccountCredentials.from_json_keyfile_name('creds.json', scope)
    client = gspread.authorize(creds)
    sheet = client.open_by_key(GSHEET_UPSOLVE).sheet1
    df = pd.DataFrame(sheet.get_all_records(), dtype=str)
    return df

# Read input data
cols = [
        "interview_start_time",
        "birth_year",
        "race:_white","race:_black_or_african_american",
        "race:_hispanic_or_latino_american",
        "race:_asian",
        "race:_native_american",
        "gender:_male/man",
        "gender:_female/woman",
        "gender:_transmale/transman",
        "gender:_transfemale/transwoman",
        "gender:_genderqueer/gender_nonconforming",
        "gender:_something_else",
        "reason_for_filing_bankruptcy:_i_lost_my_job",
        "reason_for_filing_bankruptcy:_my_hours_or_pay_was_cut_at_my_job",
        "reason_for_filing_bankruptcy:_someone_in_my_family_experienced_a_loss_of_income",
        "reason_for_filing_bankruptcy:_i_got_sick_or_injured_and_could_not_work",
        "reason_for_filing_bankruptcy:_i_received_medical_bills_i_cannot_pay",
        "reason_for_filing_bankruptcy:_i_spent_money_irresponsibly",
        "reason_for_filing_bankruptcy:_i_got_behind_on_other_bills_(e.g._utilities)",
        "reason_for_filing_bankruptcy:_my_wages_are_being_garnished",
        "reason_for_filing_bankruptcy:_i'm_going_through_a_separation_or_divorce",
        "reason_for_filing_bankruptcy:_i'm_being_evicted_or_my_house_is_being_foreclosed_on",
        "reason_for_filing_bankruptcy:_my_car_is_being_repossessed",
        "reason_for_filing_bankruptcy:_other_(please_specify)",
        "other_reason_for_filing_bankruptcy",
        "most_important_reason",
        "this_reason_is_related_to_covid-19",
        "option_tried:_cut_back_on_basic_necessities_(e.g._groceries,_rent,_utilities)",
        "option_tried:_stopped_paying_bills",
        "option_tried:_sold_or_pawned_things_i_own",
        "option_tried:_borrowed_money_from_family_and_friends",
        "option_tried:_didn't_get_medical_care_i_needed",
        "option_tried:_looked_for_another_job_or_additional_income",
        "option_tried:_debt_counseling_or_debt_modification_programs",
        "option_tried:_negotiated_with_creditors",
        "option_tried:_talked_to_a_bankruptcy_lawyer,_but_could_not_afford_their_fee",
        "what_user_would_have_done_instead_of_upsolve",
        "state",
        "zip"
    ]

df = get_data()
# df.to_csv('input/raw.csv', index=False)
czb = pd.read_csv("../_data/city_zip_boro.csv", dtype=str, engine="c")

df.columns = [i.lower().replace(" ", "_") for i in df.columns]
for col in cols:
    assert col in df.columns

# Get boro and limit to NYC
df["zip"] = df["zip"].str[:5]
df = df.loc[df.zip.isin(czb.zipcode.tolist()), :]
df["borough"] = df.zip.apply(
    lambda x: czb.loc[czb.zipcode == x, "boro"].tolist()[0]
)

df.to_csv(sys.stdout, sep='|', index=False)
