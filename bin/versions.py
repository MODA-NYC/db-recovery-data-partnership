#!/usr/bin/python3
from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.client_credential import ClientCredential
from office365.sharepoint.files.file import File
import sys
import os
import glob
import tempfile
import pandas as pd
from io import StringIO

settings=dict(
    url=os.environ['SHAREPOINT_URL'],
    client_credentials=dict(
        client_id=os.environ.get('SHAREPOINT_CLIENT_ID', ''),
        client_secret=os.environ.get('SHAREPOINT_CLIENT_SECRET', '')
    )
)

ctx = ClientContext(settings['url']).with_credentials(
ClientCredential(settings['client_credentials']['client_id'],
                    settings['client_credentials']['client_secret']))

# list version files <name>.txt under Shared%20Documents/versions
Folder = ctx.web.get_folder_by_server_relative_url('Shared%20Documents/versions')
files = Folder.files
ctx.load(files)
ctx.execute_query()
version_files = [_file.properties["ServerRelativeUrl"] for _file in files]

# Read in the <name>.txt version files into strings
versions=[]
for version_file in version_files:
    response = File.open_binary(ctx, version_file)
    versions.append(
        pd.read_csv(StringIO(response.text),
        names=['partner', 'subproduct', 'version_name', 'last_update']))

# Concatenate versions
df = pd.concat(versions)
expected = pd.read_csv(
    'https://raw.githubusercontent.com/MODA-NYC/db-recovery-data-partnership/master/recipes/_data/expected_update_cycle.csv', 
    index_col=False)
df = pd.merge(df, expected, on=['partner', 'subproduct'], how='left')\
        .sort_values(by=['partner', 'subproduct'])
temp = tempfile.NamedTemporaryFile(suffix='.csv')
df.to_csv(temp.name, index=False)

# Load in the file to file_content
with open(temp.name, 'rb') as content_file:
    file_content = content_file.read()

# Upload file to target path
target_folder = ctx.web.get_folder_by_server_relative_url('Shared%20Documents')
target_file = target_folder.upload_file('all_current_versions.csv', file_content)
ctx.execute_query()