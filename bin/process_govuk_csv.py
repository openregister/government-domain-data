#!/usr/bin/env python
import sys
import csv
import os

path = os.path.abspath('cache/govuk_domains.csv')

csv_in = csv.reader(
    open(path, 'U'),
    delimiter=",",
    dialect='unix',
    quoting=csv.QUOTE_MINIMAL
)

out_file = csv.writer(
    sys.stdout,
    delimiter=",",
    dialect='unix',
    quoting=csv.QUOTE_MINIMAL)


for line in csv_in:
    if line[0]:
        out_file.writerow(line)
