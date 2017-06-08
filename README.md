# government domain data

Data for the prototype [government-domain-data register](http://government-domain-data.openregister.org),
a list of Government domains.


# Data

## [government-domain](data/government-domain-data.tsv)

http://government-domain.discovery.openregister.org


# Lists

A list is published annually on GOV.UK
[here](https://www.gov.uk/government/publications/list-of-gov-uk-domain-names).
The data is originally supplied by JISC, who have provided the data directly to
as a spreadsheet (not included in this repo), which we have converted to a [tsv
file](lists/jisc/list.tsv).

## [GOV.UK](lists/govuk)

[GOV.UK Government
domains](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/557592/List_of_gov.uk_domains_as_of_1_Oct_2016.csv)

## [Rapid7](lists/rapid7)

[Rapid7's](lists/rapid7) [Rapid7 Project Sonar
(deprecated)](https://scans.io/study/sonar.fdns), via
[blog](https://shkspr.mobi/blog/2015/11/a-complete-list-of-every-uk-government-domain-name/).
[New](https://scans.io/study/sonar.rdns_v2) data is available.

The Sonar Project by Rapid7 gathers, among other things, 'the reverse DNS
records for all IPv4 addresses'.  That is effectively a list of domain names on
the internet, which can be filtered for ones ending '.gov.uk'.  A blogger [did
so](https://shkspr.mobi/blog/2015/11/a-complete-list-of-every-uk-government-domain-name/)
in November 2015 and made the method and results available.
