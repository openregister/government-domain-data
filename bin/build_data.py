#!/usr/bin/env python

"""
For the time being, just grab the domains from the GOV.UK list.
"""

import sys
import os
import csv

in_path = os.path.abspath('lists/govuk/govuk_domains.csv')
out_path = os.path.abspath('data/government-domain-data.tsv')

csv_in = csv.reader(open(in_path))

out_file = csv.writer(
    open(out_path, 'w'),
    delimiter="\t",
    dialect='unix',
    quoting=csv.QUOTE_MINIMAL)

out_file.writerow(['government-domain',])
next(csv_in)
for line in csv_in:
    out_file.writerow([line[0],])
