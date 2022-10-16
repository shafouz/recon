#!/usr/bin/python3

from os import environ
from time import time
import glob
import pandas as pd
import subprocess

results_path = environ.get("results")

files = glob.glob(f"{results_path}/ffuf/data/*")

results = pd.concat((pd.read_csv(f) for f in files), ignore_index=True)

# cleaned results
df_cleaned = results.drop_duplicates(['content_length', 'content_words', 'status_code']).sort_values(by="content_length", ascending=False)

# remove 429
df_cleaned = df_cleaned[df_cleaned['status_code'] != 429]

# sort
df_cleaned = df_cleaned.sort_values(by='status_code')


filename = int(time())

# print(df_cleaned)
df_cleaned.to_csv(f"{results_path}/ffuf/processed/{filename}.csv", index=False)
