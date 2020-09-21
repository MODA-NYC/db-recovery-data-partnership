from office365.runtime.auth.user_credential import UserCredential
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.files.file import File
from io import StringIO
import pandas as pd
import tempfile
import os
import geopandas as gpd
from shapely import wkb, wkt


class Site:
    def __init__(self, site_url, username, password):
        self.site_url = site_url
        self.ctx = ClientContext(site_url).with_credentials(
            UserCredential(username, password)
        )

    def create_partner(self, partner):
        return Partner(self.ctx, partner)

    @property
    def nyc_nta(self):
        return self.csv_to_gpd(
            "https://raw.githubusercontent.com/MODA-NYC/db-recovery-data-partnership/master/recipes/_data/dcp_ntaboundaries.csv"
        )

    @property
    def nyc_zipcode(self):
        return self.csv_to_gpd(
            "https://raw.githubusercontent.com/MODA-NYC/db-recovery-data-partnership/master/recipes/_data/doitt_zipcodeboundaries.csv"
        )

    @property
    def nyc_borough(self):
        return gpd.read_file(
            "https://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/NYC_Borough_Boundary/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=pgeojson"
        )

    @property
    def nyc_ctract2010(self):
        return gpd.read_file(
            "https://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/NYC_Census_Tracts_for_2010_US_Census/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=pgeojson"
        )

    @property
    def nyc_cblocks2010(self):
        return gpd.read_file(
            "https://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/NYC_Census_Blocks_for_2010_US_Census/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=pgeojson"
        )

    @property
    def us_county(self):
        return gpd.read_file(
            "https://www2.census.gov/geo/tiger/TIGER2019/COUNTY/tl_2019_us_county.zip"
        )

    @staticmethod
    def csv_to_gpd(url):
        df = pd.read_csv(url)
        df["geometry"] = df.wkb_geometry.apply(lambda x: wkb.loads(x, hex=True))
        del df["wkb_geometry"]
        return gpd.GeoDataFrame(df, geometry=df.geometry)

    @property
    def list_files_recursive(ServerRelativeUrl, file_list=[]):
        Root = self.ctx.web.get_folder_by_server_relative_url(ServerRelativeUrl)
        folders = Root.folders
        self.ctx.load(folders)
        self.ctx.execute_query()

        if len(folders) == 0:
            files = Root.files
            self.ctx.load(files)
            self.ctx.execute_query()
            for _file in files:
                file_list.append(_file.properties["ServerRelativeUrl"])

        else:
            for folder in folders:
                subfolder = folder.properties["ServerRelativeUrl"]
                list_files_recursive(subfolder, file_list=file_list)

        return file_list

    def remove_folder_recursive(ServerRelativeUrl):
        Root = self.ctx.web.get_folder_by_server_relative_url(ServerRelativeUrl)
        folders = Root.folders
        self.ctx.load(folders)
        self.ctx.execute_query()

        if len(folders) == 0:
            files = Root.files
            self.ctx.load(files)
            self.ctx.execute_query()

            for _file in files:
                _file.delete_object()
                rdp.ctx.execute_query()
                _file_ServerRelativeUrl = _file.properties["ServerRelativeUrl"]
                print(f"removed: {_file_ServerRelativeUrl}")

            Root.delete_object()
            rdp.ctx.execute_query()
            print(f"removed: {ServerRelativeUrl}")

        else:
            for folder in folders:
                subfolder_ServerRelativeUrl = folder.properties["ServerRelativeUrl"]
                remove_folder_recursive(subfolder_ServerRelativeUrl)


class Partner:
    def __init__(self, ctx, partner):
        self.ctx = ctx
        self.partner = partner

    @property
    def SiteRoot(self):
        return "/" + "/".join(self.ctx.base_url.split("/")[-2:]) + "/"

    @property
    def libraryRoot(self):
        return f"{self.SiteRoot}{self.partner}"

    def list_versions(self):
        _libraryRoot = self.ctx.web.get_folder_by_server_relative_url(self.partner)
        folders = _libraryRoot.folders
        self.ctx.load(folders)
        self.ctx.execute_query()

        versions = []
        for folder in folders:
            version = folder.properties["ServerRelativeUrl"].split("/")[-1]
            if version != "Forms":
                versions.append(
                    dict(
                        version=version,
                        relativeUrl=folder.properties["ServerRelativeUrl"],
                    )
                )
        return versions

    def list_latest(self):
        return self.list_files(version="latest")

    def list_files(self, version="latest"):
        Folder = self.ctx.web.get_folder_by_server_relative_url(
            f"{self.partner}/{version}"
        )
        files = Folder.files
        self.ctx.load(files)
        self.ctx.execute_query()

        return [
            dict(
                fileName=_file.properties["ServerRelativeUrl"].split("/")[-1],
                relativeUrl=_file.properties["ServerRelativeUrl"],
            )
            for _file in files
        ]

    def load_by_fileName(self, fileName: str, version="latest", **kwargs):
        relativeUrl = f"{self.libraryRoot}/{version}/{fileName}"
        return self.load_by_relativeUrl(relativeUrl)

    def load_by_relativeUrl(self, relativeUrl: str, **kwargs):
        ext = os.path.splitext(relativeUrl)[-1]
        if ext == ".zip":
            temp = tempfile.NamedTemporaryFile(suffix=ext)
            _file = (
                self.ctx.web.get_file_by_server_relative_url(relativeUrl)
                .download(temp)
                .execute_query()
            )
            df = pd.read_csv(temp.name, compression="zip", **kwargs)
            temp.close()
        else:
            response = File.open_binary(self.ctx, relativeUrl)
            df = pd.read_csv(StringIO(response.text), **kwargs)
        return df
