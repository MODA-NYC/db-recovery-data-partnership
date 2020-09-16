import unittest
from rdptools.core import Site
from dotenv import load_dotenv
import os


class TestPartnerMethods(unittest.TestCase):
    def setUp(self):
        load_dotenv()
        self.site_url = os.environ.get("SITE_URL")
        username = os.environ.get("USERNAME")
        password = os.environ.get("PASSWORD")
        rdp = Site(self.site_url, username, password)
        self.partner = rdp.create_partner("betanyc")

    def test_SiteRoot(self):
        SiteRoot = self.partner.SiteRoot
        _SiteRoot = "/" + "/".join(self.site_url.split("/")[-2:]) + "/"
        self.assertEqual(SiteRoot, _SiteRoot)

    def test_list_versions(self):
        versions = self.partner.list_versions()
        self.assertNotEqual(len(versions), 0)

    def test_list_files(self):
        files = self.partner.list_files()
        for _file in files:
            ext = os.path.splitext(_file["fileName"])[-1]
            self.assertIn(ext, [".txt", ".zip", ".csv"])


if __name__ == "__main__":
    unittest.main()
