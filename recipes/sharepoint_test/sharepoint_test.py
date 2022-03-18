

from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.client_credential import ClientCredential
import sys
import os
import glob
from io import StringIO, BytesIO
import pandas as pd
#from dotenv import load_dotenv

#load_dotenv()

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

web = ctx.web
ctx.load(web)
ctx.execute_query()
print("Web title: {0}".format(web.properties['Title']))
