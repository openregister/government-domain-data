# Convert the spreadsheet provided by JISC to tsv, omitting some columns.

# Populate 'organisation' with curies to government-organisation,
# local-authority-eng, and local-authority-sct, by:
# * exact match (889)
# * exact match after removing punctuation and stopwords (58)
# * fuzzy match confirmed manually (54 confirmed out of 485)
# * no match: 1910, but that's expected because we don't have
#   principal-local-authority (Wales) or local-authority-ni yet, and many
#   organisations aren't among even them.

library(tidyverse)
library(readxl)
library(stringi)
library(fuzzyjoin)
library(tidytext)

tsv_path <- "../data/government-domain-data.tsv"

# Function to remove stopwords and punctuation
# * of
# * for
# * the
# * and
# * (
# * )
# * &
# * ,
# * '
clean <- function(string) {
  string %>%
    tolower %>%
    stri_replace_all_fixed(c(" of ", " for ", " the ", " and ", "(", ")",
                             " & ", ", ", "'", "-"),
                           c(" ",    " ",     " ",     " ",     "",  "",
                             " ",   " ", "",   " "),
                         vectorize_all = FALSE) %>%
    stri_trim()
}

# Load the JISC-supplied spreadsheet
jisc <-
  read_excel("../lists/jisc/jisc.xlsx", skip = 3) %>%
  filter(!is.na(`Domain Name`),
         Status != "Suspended") %>% # Omit blanks due to merged cells
  select(`Domain Name`,
         `Owner`) %>%
  rename(`government-domain` = `Domain Name`,
         org_original = `Owner`) %>%
  mutate(`organisation` = clean(org_original ))

# Download the government-organisation register
gov_org <-
  read_csv("https://government-organisation.register.gov.uk/records.csv?page-size=5000") %>%
  select(`name`,
         `government-organisation`) %>%
  rename(`organisation` = `name`,
         curie = `government-organisation`) %>%
  mutate(curie = paste0("government-organisation:", curie))

# Download the various local-authority registers
la_eng <-
  read_csv("https://local-authority-eng.register.gov.uk/records.csv?page-size=5000") %>%
  select(`official-name`,
         `local-authority-eng`) %>%
  rename(`organisation` = `official-name`,
         curie = `local-authority-eng`) %>%
  mutate(curie = paste0("local-authority-eng:", curie))

la_sct <-
  read_csv("https://local-authority-sct.register.gov.uk/records.csv?page-size=5000") %>%
  select(`official-name`,
         `local-authority-sct`) %>%
  rename(`organisation` = `official-name`,
         curie = `local-authority-sct`) %>%
  mutate(curie = paste0("local-authority-sct:", curie))

# Wales and Northern Ireland aren't in yet in beta

# Combine government organisations and local authorities
organisation <-
  bind_rows(gov_org, la_eng, la_sct) %>%
  rename(org_original = organisation) %>%
  mutate(organisation = clean(org_original))

# Fuzzyjoin domain organisations to all organisations
# authorities

exact_match <- # exact match by the given organisation names
  jisc %>%
  inner_join(organisation, by = "org_original") %>%
  select(`government-domain`,
         org_original,
         curie)

jisc_remainder <- anti_join(jisc, exact_match, by = "org_original")

exact_match_stopped <- # exact match by stop-worded organisation names
  jisc_remainder %>%
  inner_join(organisation, by = "organisation") %>%
  select(`government-domain`,
         org_original = org_original.x,
         curie)

jisc_remainder <- anti_join(jisc_remainder, exact_match_stopped, by = "org_original")

fuzzy <- # fuzzy match by stop-worded organisation names
  jisc_remainder %>%
  filter(!is.na(organisation)) %>% # Can't fuzzyjoin on NA
  stringdist_left_join(organisation,
                       by = "organisation",
                       method = "jw",
                       max_dist = .18,
                       distance_col = "score") %>%
  select(-organisation.x, -organisation.y) %>%
  filter(!is.na(org_original.y)) %>% # No match met the threshold
  # Select only the best match
  group_by(org_original.x) %>%
  arrange(org_original.x, score) %>%
  slice(1) %>%
  ungroup() %>%
  arrange(org_original.y, org_original.x) # Nicer to read

write_csv(fuzzy, "fuzzy.csv")

# MANUAL STEP HERE!

# Then continue making the tsv

manual_match <- read_csv("./manual-match.csv")

matched <-
  bind_rows(exact_match,
            exact_match_stopped,
            manual_match) %>%
  select(`government-domain`,
         `organisation` = curie) %>%
  mutate(`start-date` = NA,
         `end-date` = NA)

unmatched <-
  jisc %>%
  anti_join(matched, by = "government-domain") %>%
  select(`government-domain`)

# Write the register tsv file, using write.table instead of write_tsv in order
# to quote the 'area' column.  Unfortunately doing so means that the headers are
# all quoted, so the headers are written separately.
cat(paste0(paste(colnames(matched), collapse = "\t"), "\n"),
    file = tsv_path)
bind_rows(matched, unmatched) %>%
  arrange(`government-domain`) %>% 
write.table(tsv_path,
            sep = "\t",
            row.names = FALSE,
            quote = 2,
            col.names = FALSE,
            append = TRUE,
            na = "")
