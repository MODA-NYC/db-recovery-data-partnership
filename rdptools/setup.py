from setuptools import setup, find_packages
from os import path

this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, "README.md"), encoding="utf-8") as f:
    long_description = f.read()

setup(
    name="rdptools",
    version="0.1.7",
    description="recovery data partnership python package",
    long_description=long_description,
    long_description_content_type="text/markdown",
    pacakges=find_packages(),
    install_requires=["pandas", "office365-rest-client==2.2.0", "geopandas"],
)
