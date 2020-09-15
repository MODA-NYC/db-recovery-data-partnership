from setuptools import setup, find_packages

setup(name='rdptools',
      version='0.1.4',
      description='recovery data partnership python package',
      pacakges=find_packages(),
      install_requires=[
          'pandas',
          'office365-rest-client=2.2.0'
      ]
    )