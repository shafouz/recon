#!/usr/bin/env python3

import re
import requests
import time

def getJWT():
    cookies = {
    }
    r = requests.get("https://example.com/account/accesstoken", cookies=cookies)
    return r.text

print(getJWT(), end='')
