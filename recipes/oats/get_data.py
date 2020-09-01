from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd
import os

# Authenticate google api service
gauth = GoogleAuth()
scope = ['https://www.googleapis.com/auth/drive']
gauth.credentials = ServiceAccountCredentials.from_json_keyfile_name('creds.json', scope)
drive = GoogleDrive(gauth)

# List all files
file_list = drive.ListFile({'q': f"'{os.environ['GDRIVE_OATS']}' in parents and trashed=false"}).GetList()
df=pd.DataFrame(file_list)
df.sort_values(by='createdDate',ascending=False, inplace=True)

# Download the latest file
file_id=df.loc[0, 'id']
target_file = drive.CreateFile({'id': file_id})
target_file.FetchContent()
content_string = target_file.content.getvalue()

# Write content string to directory
with open(f'input/raw.xlsx', 'wb') as fi:
    fi.write(content_string)