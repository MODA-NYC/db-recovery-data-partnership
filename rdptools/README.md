# rdptools

[![PyPI version](https://badge.fury.io/py/rdptools.svg)](https://badge.fury.io/py/rdptools) [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/MODA-NYC/db-recovery-data-partnership/blob/master/examples/example_data_import.ipynb)

rdptools is a python package that simplifies data pulling from the **RDPDataRepository** sharepoint site. To use this package you will need to obtain the following information:

1. the RDPDataRepository sharepoint site url
2. Your agency issued email login and password
3. access permission to specific data partnerships

## Installation

```bash
pip install rdptools
```

## Examples

### Authentication

```python
from rdptools.core import Site
import pandas as pd

site_url = "https://<organization>.sharepoint.com/<site>"
username = "<your>@<email>.<provider>"
password = "<your password>"
rdp=Site(site_url, username, password)
```

### Create access to a data partner

```python
betanyc = rdp.create_partner('betanyc')
```

### Listing data versions available

```python
betanyc.list_versions()
```

    [
        {
            'version': 'latest',
            'relativeUrl': '/sites/RDPDataRepository/betanyc/latest'
        },
        {
            'version': '2020-09-11',
            'relativeUrl': '/sites/RDPDataRepository/betanyc/2020-09-11'
        },
        ...
    ]

### Listing files available under each version folder

```python
betanyc.list_files()
```

    [
        {
            'fileName': 'version.txt',
            'relativeUrl': '/sites/RDPDataRepository/betanyc/latest/version.txt'
        },
        {
            'fileName': 'betanyc.csv',
            'relativeUrl': '/sites/RDPDataRepository/betanyc/latest/betanyc.csv'
        },
        ...
    ]

> Note that by deafult it's listing version `latest`. If you would like to access an older version. you can do the following:

```python
betanyc.list_files(version='2020-09-11')
```

### Read a file to a pandas dataframe

By deafult, it's loading the latest version. However you can also specify which version you would like to read. e.g.

```python
df = betanyc.load_by_fileName('betanyc.csv')
# df = betanyc.load_by_fileName('betanyc.csv', version='2020-09-10')
# df = betanyc.load_by_fileName('betanyc.csv', version='latest')
df.head()
```

> Note that you can also read a file through relative url. e.g.

```python
df = betanyc.load_by_relativeUrl('/sites/RDPDataRepository/betanyc/latest/betanyc.csv')
```

Both `load_by_relativeUrl` and `load_by_fileName` are wrappers of `pd.read_csv`, so you can pass arguments accepted by `pd.read_csv` to customize your data import process. e.g.

```python
df = betanyc.load_by_fileName('betanyc.csv', dtype=str, nrows=5)
```

### Special cases

When dealing with data partners that share multiple data products. you would have to specify which data product you would like to look at. e.g.

```python
cuebiq_daily=rdp.create_partner('cuebiq/cuebiq_daily')
```

Sometimes large csv files are zipped then uploaded to sharepoint. Decompression is automatically handled by `load_by_fileName` and `load_by_relativeUrl` so you can read them the same way as you read a csv. e.g.

```python
df=cuebiq_daily.load_by_fileName('cuebiq_daily.zip')
```

### Geospatial

coming ....
