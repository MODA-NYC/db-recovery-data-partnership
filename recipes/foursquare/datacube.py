from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from oauth2client.service_account import ServiceAccountCredentials
from sqlalchemy import create_engine
import pandas as pd
import os

# Authenticate google api service
gauth = GoogleAuth()
scope = ['https://www.googleapis.com/auth/drive']
gauth.credentials = ServiceAccountCredentials.from_json_keyfile_name('creds.json', scope)
drive = GoogleDrive(gauth)

# Create Engine
engine = create_engine(os.environ['RDP_DATA'])

# List all files
def get_date(title:str) -> str:
    if '2020' not in title:
        return '2020' + title.replace('.tar.gz', '').replace('data-cube2', '')
    return title.replace('.tar.gz', '').replace('data-cube2-', '')

file_list = drive.ListFile({'q': f"'{os.environ['GDRIVE_FOURSQUARE']}' in parents and trashed=false"}).GetList()
df=pd.DataFrame(file_list)
df.sort_values(by='createdDate',ascending=False, inplace=True)
df['date'] = df.title.apply(get_date)
available_dates=df.date.to_list()

# List dates that's already loaded
loaded=pd.read_sql(sql='''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'foursquare_zipcode'
    AND table_name not in ('main', 'latest')
''', con=engine)
loaded_dates=loaded.table_name.to_list()

for i in available_dates:
    if i not in loaded_dates:
        print(f'pulling date {i}')
        file_id=df.loc[df.date == i, 'id'].to_list()[0]
        file_name=f'{i}.tar.gz'
        target_file = drive.CreateFile({'id': file_id})
        target_file.FetchContent()
        content_string = target_file.content.getvalue()

        # Write content string to directory
        with open(f'input/{file_name}', 'wb') as fi:
            fi.write(content_string)