from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd
import os

# Authenticate
gauth = GoogleAuth()
scope = ['https://www.googleapis.com/auth/drive']
gauth.credentials = ServiceAccountCredentials.from_json_keyfile_name('creds.json', scope)
drive = GoogleDrive(gauth)

# Listing file and pick the latest file
file_list = drive.ListFile({'q': f"'{os.environ['GDRIVE_FOURSQUARE']}' in parents and trashed=false"}).GetList()
df=pd.DataFrame(file_list)
df.sort_values(by='createdDate',ascending=False, inplace=True)

# Download the latest file and write to content_string
file_id=df.loc[0, 'id']
file_name=df.loc[0, 'title']
target_file = drive.CreateFile({'id': file_id})
target_file.FetchContent()
content_string = target_file.content.getvalue()

# Write content string to directory
with open(f'input/{file_name}', 'wb') as fi:
    fi.write(content_string)