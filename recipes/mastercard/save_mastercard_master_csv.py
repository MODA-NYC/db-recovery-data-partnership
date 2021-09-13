import os
import aws
from aws import Aws
import pandas as pd
import boto3
from pathlib import Path


aws = Aws(
    aws_region_name='us-east-1',
    aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
    aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"],
    rdp_access_key_id=os.environ["RDP_ACCESS_KEY_ID"],
    rdp_secret_access_key=os.environ["RDP_SECRET_ACCESS_KEY"],

)

#get dataframe from Athena
query = '''
SELECT * 
FROM mastercard.extracted_2
ORDER BY txn_date DESC
'''
output_csv_path =f"output/dev/mastercard/mastercard_master_latest.csv"
aws.execute_query(
    query=query,
    database="safegraph",
    output=output_csv_path
)