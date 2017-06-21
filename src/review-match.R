# Review the matching algorithm and its success, having manually checked every
# record.

library(tidyverse)
library(googlesheets)
library(stringr)

# One-off, or to switch users)
# gs_auth(new_user = TRUE)

before <-
  read_tsv("./before-manual-match.tsv") %>%
  select(hostname, organisation)
after <-
  read_tsv("./after-manual-match.tsv") %>%
  select(hostname, organisation)
org_names <-
  read_tsv("../lists/jisc/jisc.tsv") %>%
  rename(hostname = `government-domain`,
         org_name = org_original) %>%
  select(hostname, org_name) %>%
  mutate(hostname = str_replace(hostname, "\\.gov\\.uk$", ""))

curie <- function(x) {
  str_extract(x, "^[^:]+")
}

errors <-
  before %>%
  inner_join(after, by = "hostname") %>%
  inner_join(org_names, by = "hostname") %>%
  mutate(curie.x = curie(organisation.x),
         curie.y = curie(organisation.y))
write_tsv(errors, "errors.tsv")

# None were the wrong register, good!
errors %>%
  filter(!(curie.x == curie.y))

# None were the wrong organisation.  Too cautious?
errors %>%
  filter(!(organisation.x == organisation.y))

# 999 were auto-matched or auto-assisted
errors %>%
  filter(!is.na(organisation.x))

# 1901 were not auto-matched
errors %>%
  filter(is.na(organisation.x))

# Of which, 1584 weren't even manually matched
errors %>%
  filter(is.na(organisation.x),
         is.na(organisation.y))

# So only 327 further matches were found 100% manually
errors %>%
  filter(is.na(organisation.x),
         !is.na(organisation.y))

total <- 2911
exact_match <- 889 + 58 # 58 found after stopword/punctuation/lowercase
fuzzy_attempted <- 249
fuzzy_confirmed <- 53
manual <- 327
no_match <- 1584
yes_match <- total - no_match

exact_match + fuzzy_confirmed + manual + no_match # Equals the total

manual / yes_match # 24% of all matches were found manually
exact_match / yes_match # 71% matched exactly (including stopword/puntuation/lowercase)
fuzzy_confirmed / yes_match # 4% matched by real data science + human confirmation
