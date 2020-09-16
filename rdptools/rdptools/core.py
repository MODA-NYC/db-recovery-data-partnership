from office365.runtime.auth.user_credential import UserCredential
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.files.file import File
from io import StringIO
import pandas as pd
import tempfile
import os
import geopandas as gpd
from shapely import wkb, wkt

class Site():
    def __init__(self, site_url, username, password):
        self.ctx = ClientContext(site_url)\
                    .with_credentials(UserCredential(username, password))

    def create_partner(self, partner):
        return Partner(self.ctx, partner)

    @property
    def nta(self):
        return self.csv_to_gpd('https://raw.githubusercontent.com/MODA-NYC/db-recovery-data-partnership/master/recipes/_data/dcp_ntaboundaries.csv')

    @property
    def zipcode(self):
        return self.csv_to_gpd('https://raw.githubusercontent.com/MODA-NYC/db-recovery-data-partnership/master/recipes/_data/doitt_zipcodeboundaries.csv')

    @staticmethod
    def csv_to_gpd(url):
        df=pd.read_csv(url)
        df['geometry']=df.wkb_geometry.apply(lambda x : wkb.loads(x, hex=True))
        del df['wkb_geometry']
        return gpd.GeoDataFrame(df, geometry=df.geometry)

class Partner():
    def __init__(self, ctx, partner):
        self.ctx = ctx
        self.partner=partner

    @property
    def SiteRoot(self):
        root=self.ctx.web.get_folder_by_server_relative_url('')
        self.ctx.load(root)
        self.ctx.execute_query()
        return root.properties['ServerRelativeUrl']

    @property
    def libraryRoot(self):
        return f'{self.SiteRoot}{self.partner}'

    def list_versions(self):
        _libraryRoot = self.ctx.web.get_folder_by_server_relative_url(self.partner)
        folders = _libraryRoot.folders
        self.ctx.load(folders)
        self.ctx.execute_query()

        versions = []
        for folder in folders:
            version=folder.properties['ServerRelativeUrl'].split('/')[-1]
            if version != 'Forms':
                versions.append(dict(
                    version=version,
                    relativeUrl=folder.properties['ServerRelativeUrl']
                ))
        return versions
    
    def list_latest(self):
        return self.list_files(version='latest')

    def list_files(self, version='latest'):
        Folder = self.ctx.web.get_folder_by_server_relative_url(f'{self.partner}/{version}')
        files = Folder.files
        self.ctx.load(files)
        self.ctx.execute_query()

        return [dict(
            fileName=_file.properties["ServerRelativeUrl"].split('/')[-1],
            relativeUrl=_file.properties["ServerRelativeUrl"]
        ) for _file in files]

    def load_by_fileName(self, fileName:str, version='latest', **kwargs):
        relativeUrl=f'{self.libraryRoot}/{version}/{fileName}'
        return self.load_by_relativeUrl(relativeUrl)

    def load_by_relativeUrl(self, relativeUrl:str, **kwargs):
        ext=os.path.splitext(relativeUrl)[-1]
        if ext == '.zip':
            temp=tempfile.NamedTemporaryFile(suffix=ext)
            _file = self.ctx.web\
                        .get_file_by_server_relative_url(relativeUrl)\
                        .download(temp).execute_query()
            df=pd.read_csv(temp.name, compression='zip', **kwargs)
            temp.close()
        else:
            response = File.open_binary(self.ctx, relativeUrl)
            df=pd.read_csv(StringIO(response.text), **kwargs)
        return df