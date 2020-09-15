from setuptools import setup, find_packages

setup(name='rdptools',
      version='0.1.1',
      description='recovery data partnership python package',
      pacakges=find_packages(),
      install_requires=[
          'pandas',
          'Office365-REST-Python-Client==2.2.0'
      ]
    )