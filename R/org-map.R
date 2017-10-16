# Build a map from JISC organisation names to CURIEs.

library(tidyverse)
library(readxl)
library(stringr)
library(RegistersClientR)
library(here)

# The original JISC file that was mapped to CURIES
jisc_2017_06_08 <-
  read_excel(here("lists", "jisc", "jisc-2017-06-08.xlsx"), skip = 2) %>%
  rename(hostname = `Domain Name`) %>%
  select(hostname, Owner, Representing) %>%
  mutate(hostname = str_replace(hostname, "\\.gov\\.uk$", ""))

# The original register in Alpha, with owners mapped to CURIES
register_2017_07_14 <-
  read_tsv("https://raw.githubusercontent.com/openregister/government-domain-data/c1b72ed282259ae986bf3b70b1f137891dd6f089/data/government-domain-data.tsv")

# A map from owners to CURIEs, at the initial mapping
curie_2017_07_14 <-
  register_2017_07_14 %>%
  filter(!is.na(organisation)) %>%
  select(hostname, organisation) %>%
  inner_join(jisc_2017_06_08, by = "hostname")

# Check for different CURIEs mapped to the same owner
curie_2017_07_14 %>%
  distinct(Owner, organisation) %>%
  count(Owner, sort = TRUE) %>%
  filter(n > 1)

# Examine where different CURIEs were mapped to the same owner
curie_2017_07_14 %>%
  filter(Owner %in% c("Department for Communities", "HM Government Cabinet Office")) %>%
  arrange(Owner, organisation, hostname) %>%
  print(n = Inf)

# I think someone used the Representing field instead of the Owner field, when
# looking up CURIEs.  They should be corrected as follows (file in
# lists/map-correction.tsv.

map_correction <-
  read_tsv(here("lists", "map-correction.tsv")) %>%
  mutate(`start-date` = strftime(`start-date`, "%Y-%m-%d"),
         `end-date` = strftime(`end-date`, "%Y-%m-%d"))

map_correction
# # A tibble: 6 x 5
#   `government-domain`                  hostname                   organisation `start-date` `end-date`
#                 <int>                     <chr>                          <chr>        <chr>      <chr>
# 1                7448            volcomgrantsni government-organisation:OT1173   2003-02-12       <NA>
# 2                6539                     proni government-organisation:OT1173   2002-10-09       <NA>
# 3                4762                     dsdni government-organisation:OT1173   2005-04-18       <NA>
# 4                4637                    dcalni government-organisation:OT1173   2006-08-18       <NA>
# 5               15597 boundarycommissionengland  government-organisation:PB337   2014-11-05       <NA>
# 6               15644                     acoba     government-organisation:D2   2014-11-27       <NA>

# Build the CURIE map without those errors (this time include unmapped owners)
curie_map_2017_07_14 <-
  register_2017_07_14 %>%
  filter(!(hostname %in% c("dcalni", "dsdni", "proni", "volcomgrantsni", "acoba", "boundarycommissionengland"))) %>%
  inner_join(jisc_2017_06_08, by = "hostname") %>%
  distinct(Owner, organisation)

# The 2017-09-06 JISC file to be mapped to CURIES
jisc_2017_09_06 <-
  read_excel(here("lists", "jisc", "Government_Domain_Register_Report 06Sept2017.xlsx")) %>%
  rename(hostname = `Domain Name`) %>%
  select(hostname, Owner, Representing) %>%
  mutate(hostname = str_replace(hostname, "\\.gov\\.uk$", ""))

jisc_2017_09_06 %>%
  anti_join(curie_map_2017_07_14, by = "Owner") %>%
  print(n = Inf)

# New maps to be created for the 2017-09-06 data:

# Natural Resources Wales = government-organisation:OT1103
# Innovate UK = government-organisation:PB1078

curie_map_2017_09_06 <-
  bind_rows(curie_map_2017_07_14,
            tribble(                            ~Owner,                    ~organisation,
                         "Alderminster Parish Council",                               NA,
                             "Natural Resources Wales", "government-organisation:OT1103",
                        "Batchworth Community Council",                               NA,
                             "St.Agnes Parish Council",                               NA,
                         "High Halstow Parish Council",                               NA,
                             "Orgreave Parish Council",                               NA,
                              "Sancton Parish Council",                               NA,
                             "Ringmore Parish Council",                               NA,
                                "Crich Parish Council",                               NA,
                                         "Innovate UK", "government-organisation:PB1078",
                               "Milton Parish Council",                               NA,
                   "Bridgwater Without Parish Council",                               NA,
                         "Long Melford Parish Council",                               NA,
                      "Hemingford Grey Parish Council",                               NA,
            "Itchen Stoke and Ovington Parish Council",                               NA,
                              "New Mills Town Council",                               NA,
                        "Batchworth Community Council",                               NA,
                             "St Teath Parish Council",                               NA,
                              "Measham Parish Council",                               NA,
                            "West Hill Parish Council",                               NA,
              "Nythe, Eldene and Liden Parish Council",                               NA))

# The 2017-10-05 JISC file to be mapped to CURIES
jisc_2017_10_05 <-
  read_excel(here("lists", "jisc", "Government_Domain_Register_Report 5Oct2017.xlsx")) %>%
  rename(hostname = `Domain Name`) %>%
  select(hostname, Owner, Representing) %>%
  mutate(hostname = str_replace(hostname, "\\.gov\\.uk$", ""))

jisc_2017_10_05  %>%
  anti_join(curie_map_2017_09_06, by = "Owner") %>%
  print(n = Inf)

# New maps to be created for the 2017-09-06 data:

# Natural Resources Wales = government-organisation:OT1103
# Innovate UK = government-organisation:PB1078

curie_map_2017_10_05 <-
  bind_rows(curie_map_2017_07_14,
            tribble(               ~Owner, ~organisation,
        "Hampshire Fire & Rescue Service",            NA,
                "Padworth Parish Council",            NA,
       "Moss and District Parish Council",            NA,
                  "Lutton Parish Council",            NA,
                 "Holford Parish Council",            NA,
                  "Exning Parish Council",            NA,
"Stoke Lodge & The Common Parish Council",            NA,
   "Central Swindon North Parish Council",            NA,
            "West Swindon Parish Council",            NA,
               "Quethiock Parish Council",            NA,
    "Sturminster Marshall Parish Council",            NA,
        "The Small Business Commissioner",            NA,
              "Greater Manchester Police",            NA))

org_map <- curie_map_2017_10_05
