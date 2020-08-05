import requests
import json
import time
from helper import NYC, DATES, v
import itertools
from multiprocessing import Pool, cpu_count

base_url = f"https://api.foursquare.com/v2/demo/recoveryindex/data?getOptions=false&oauth_token=4DOQA5U052PCTDHZR1XH02ZQZUAHVWL2VQS53ON11I1H00Z2&v={v}&wsid=QNQHRAJNEF2DFYC40GH1W0CA5JW3S2"
combo = sum([list(itertools.product([i["county"]], DATES, i["zips"])) for i in NYC], [])


def get_index(record, sleep=0):
    url = f"{base_url}&city=&county={record[0]}&dt={record[1]}&geoPivotCategory=&neighborhood=&state=New%20York&zip={record[2]}"
    try:
        r = requests.get(url)
        print(r.headers['X-RateLimit-Remaining'])
        result=r.json()["response"]["rows"]
        result.update(dict(county=record[0], date=record[1], zipcode=record[2]))
        return result
    except:
        time.sleep(2 * sleep)
        print(url)
        print(f'retrying after sleeping {2*sleep}s')
        return get_index(record, sleep+1)

with Pool(processes=cpu_count()) as pool:
    it = pool.map(get_index, combo, 50)
