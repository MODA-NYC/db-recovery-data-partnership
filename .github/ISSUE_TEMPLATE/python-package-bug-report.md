---
name: Python Package Bug Report
about: Create a report to help us improve
title: ''
labels: rdptools
assignees: mgraber, SPTKL

---

**Describe the bug**
A clear and concise description of what the bug is. you can also include the error message

**To Reproduce**
include a code snippet here
```python
from rdptools.core import Site
import pandas as pd

site_url = "https://<organization>.sharepoint.com/<site>"
username = "<your>@<email>.<provider>"
password = "<your password>"
rdp=Site(site_url, username, password)
```

**Expected behavior**
A clear and concise description of what you expected to happen.

**Additional context**
Add any other context about the problem here.
