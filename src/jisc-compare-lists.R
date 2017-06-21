# JISC sent an updated list.  This script compares the two.

library(tidyverse)
library(readxl)

# Load the two JISC-supplied spreadsheets
jisc1 <-
  read_excel("../lists/jisc/jisc.xlsx", skip = 3) %>%
  filter(!is.na(`Domain Name`),
         Status != "Suspended") # Omit blanks due to merged cells
jisc2 <-
  read_excel("../lists/jisc/jisc-2017-06-08.xlsx", skip = 3) %>%
  filter(!is.na(`Domain Name`),
         Status != "Suspended") # Omit blanks due to merged cells

jisc2 <- read_excel("../lists/jisc/jisc.xlsx", skip = 3)
  filter(!is.na(`Domain Name`),
         Status != "Suspended") %>% # Omit blanks due to merged cells
  select(`Domain Name`,
         `Owner`) %>%
  rename(`government-domain` = `Domain Name`,
         org_original = `Owner`) %>%
  mutate(`organisation` = clean(org_original ))

