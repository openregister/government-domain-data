# Script to reconcile the latest monthly list with the previous one.
# Finds records that have been:
# * created
# * deleted
# * updated

# The point of comparison is the *previouus spreadsheet*, not the *current
# register*, because JISC still uses its own names.

# This is hardcoded to the September reconciliation, because the new file has a
# different structure from the original one.



# 16:54]
# Duncan Garmonsway Reviewing your pull request for gov-domains.  We might have been at cross-purposes when we discussed the 'owner' and 'representing' column.  Neither of them should be in the register -- either we find a CURIE for the owner to put in the 'organisation' column, or we forget about it.  Does that make sense?  Do you agree?  Unlike the public-body register, which has to have at least a free-text 'name' column otherwise there's nothing left -- for gov-domain we always have the domain, and don't absolutely require anything else.


# [16:59]
# I can do my own PR if you like?


# [17:01]
# The good news is that we agree on additions/deletions :slightly_smiling_face:


# [17:12]
# Duncan Garmonsway Small number of owner changes too.
# ```               `Domain Name`                              Owner.x                              Owner.y
#                        <chr>                                <chr>                                <chr>
# 1     alderminster-pc.gov.uk   Stratford-on-Avon District Council          Alderminster Parish Council
# 2       batchworth-pc.gov.uk            Batchworth Parish Council         Batchworth Community Council
# 3                 hsl.gov.uk         Health and Safety Laboratory          Health and Safety Executive
# 4 llwybrarfordircymru.gov.uk        Countryside Council for Wales              Natural Resources Wales
# 5          pesticides.gov.uk Food and Environment Research Agency          Health and Safety Executive
# 6      walescoastpath.gov.uk        Countryside Council for Wales              Natural Resources Wales
# 7    westofengland-ca.gov.uk                 Bristol City Council Bath and North East Somerset Council```

library(tidyverse)
library(readxl)
library(RegistersClientR)
library(stringr)
library(here)

list_old <-
  read_excel((here("lists", "jisc", "Government_Domain_Register_Report 06Sept2017.xlsx"))) %>%
  mutate(`Domain Name` = str_replace(`Domain Name`, "\\.gov\\.uk$", ""))

list_new <- read_excel(file.path(here("lists", "jisc", "Government_Domain_Register_Report 5Oct2017.xlsx"))) %>%
  mutate(`Domain Name` = str_replace(`Domain Name`, "\\.gov\\.uk$", ""))

current <- read_tsv(here("data", "government-domain-data.tsv"))

# Are any current records end-dated?
filter(current, !is.na(`end-date`))
# No.  Why not?  Surely some were deleted in a previous update?

# Does the new list have start and end dates?
anyNA(list_new$`Start Date`)
anyNA(list_new$`End Date`) # No end dates.  Check with Jamie and then JISC.

# Has anything changed between list_old and current -- i.e. via custodian update
# tool?
anti_join(list_old, current, by = c("Domain Id" = "government-domain"))
# Yes, 4710 digitv is missing from current that was in list_old.  Is it in
# list_new?
filter(list_new, `Domain Id` == 4710)
filter(list_new, `Domain Name` == "digitv")
# No, so it should be added with an end-date of this month.
add1 <- data_frame(`government-domain` = 4710,
                   hostname = "digitv",
                   organisation = NA,
                   `start-date` = "2017-09-06",
                   `end-date` = "2017-10-04")

anti_join(current, list_old, by = c("government-domain" = "Domain Id"))
# Also there are several domains in current that aren't in list_old.  Digging
# through the git log, it seems there's an uncommited JISC file that added start
# dates and some more domains to the one that was committed.

# Are those domains still in list_new?
anti_join(current, list_old, by = c("government-domain" = "Domain Id")) %>%
  inner_join(list_new, by = c("government-domain" = "Domain Id"))
# Yes, so they will be left, and can be ignored.

# Do any IDs have new hostnames?
inner_join(current, list_old, by = c("government-domain" = "Domain Id")) %>%
  filter(`Domain Name` != hostname)
# No.

# Do any IDs have new owners?  We compare via the org_map dataframe, which is
# created by the R/org-map.R script.
list_old %>%
  left_join(org_map) %>%
  inner_join(filter(current, !is.na(organisation)),
             by = c("Domain Id" = "government-domain")) %>%
  filter(organisation.x != organisation.y) %>%
  select(`Domain Id`, `Domain Name`, `Owner`, organisation.x, organisation.y)
# Yes, but these will be corrected by the org_map correction.

# Has anything changed between list_new and current?
anti_join(list_new, current, by = c("Domain Id" = "government-domain"))
# Yes, there are some new entries, written to lists/new-entries.tsv
add2 <-
  anti_join(list_new, current, by = c("Domain Id" = "government-domain")) %>%
  rename(`government-domain` = `Domain Id`,
         hostname = `Domain Name`,
         `start-date` = `Start Date`) %>%
  mutate(organisation = NA,
         `start-date` = strftime(`start-date`, "%Y-%m-%d"),
         `end-date` = NA) %>%
  select(`government-domain`,
         hostname,
         organisation,
         `start-date`,
         `end-date`)

# Some entries have also gone
anti_join(current, list_new, by = c("government-domain" = "Domain Id"))
delete1 <-
  anti_join(current, list_new, by = c("government-domain" = "Domain Id")) %>%
  mutate(`start-date` = strftime(`start-date`, "%Y-%m-%d"),
         `end-date` = "2017-10-04")

# Do any IDs have new hostnames?
inner_join(current, list_new, by = c("government-domain" = "Domain Id")) %>%
  filter(`Domain Name` != hostname)
# No.

# Do any IDs have new owners?  We compare via the org_map dataframe, which is
# created by the R/org-map.R script.
list_new %>%
  left_join(org_map) %>%
  inner_join(filter(current, !is.na(organisation)),
             by = c("Domain Id" = "government-domain")) %>%
  filter(organisation.x != organisation.y) %>%
  select(`Domain Id`, `Domain Name`, `Owner`, organisation.x, organisation.y)
# Yes, but these will be corrected by the org_map correction.

bind_rows(map_correction, add1, add2, delete1) %>%
  print(n = Inf) %>%
  write_tsv(here("lists", "append-entries-2017-10-05.tsv"))
