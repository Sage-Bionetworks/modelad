library(tidyverse)
library(synapser)
library(synapserutils)

# Context: Individual metadata were missing as explained in this issue:
# https://github.com/Sage-Bionetworks/magora/issues/79
# Summary: v10 missing 12 animals that are in v7. Add v7 animals to
# latest version. These are the 4xxx series animals
# Missing individaulIDs: 4199 4204 4208 4209 4242 4244 4255 4264 4265 4266 4281 4503
# Goals: Specimens were also missing from biospecimen file as identifie din this issue:
# https://github.com/Sage-Bionetworks/magora/issues/82

# https://www.synapse.org/#!Synapse:syn18876530

# BRAINSTORM PROCESS
# Context:
# https://github.com/Sage-Bionetworks/magora/issues/79
# https://github.com/Sage-Bionetworks/magora/issues/82
# [study](https://www.synapse.org/#!Synapse:syn16798076)
# [biospecimen_v08](https://www.synapse.org/#!Synapse:syn18876530.8)
# [biospecimen_v06](https://www.synapse.org/#!Synapse:syn18876530.6)

synLogin(silent = TRUE)
setwd("~/GitHub/sageCuration/2022-02-28-UCI_5XFAD/")

# METADATA
biospecimen_v06 <-
  synGet(
    "syn18876530",
    version = 6,
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
biospecimen_v08 <-
  synGet(
    "syn18876530",
    version = 8,
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
individual <-
  synGet(
    "syn18880070",
    version = 12,
    # (v11 with 308 records x 36 cols)
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
bio_v06 <- biospecimen_v06$path %>% read_csv()
bio_v08 <- biospecimen_v08$path %>% read_csv()
ind_v12 <- individual$path %>% read_csv()


# Compare metadata frames
dplyr::all_equal(bio_v06, bio_v08)
janitor::compare_df_cols(bio_v06, bio_v08)
length(unique(bio_v06$specimenID))
length(unique(bio_v08$specimenID))

# Which IDs are missing from biospecimen file?
missing_individualID <-
    anti_join(bio_v06, bio_v08, by = c("individualID")) %>%
    select(individualID) %>%  unique() %>% arrange()
missing_individualID %>%
    write.csv(., file = "missing_individualID_from_bio_v08.csv", row.names = FALSE)
missing_specimenID <-
    anti_join(bio_v06, bio_v08, by = c("specimenID")) %>%
    select(individualID, specimenID) %>%  arrange(individualID)
missing_specimenID %>%
    write.csv(., file = "missing_specimenID_from_bio_v08.csv", row.names = FALSE)

# Forensics - What remapping took place? What doesn't match up?
missing_individualID # only includes 4000-series individualIDs

bio_v06 %>% filter(individualID==275) %>% select(1,2,5)
bio_v08 %>% filter(individualID==275) %>% select(1,2,5)

# pattern <- "[LR]H|[is]f|r[ch]|p|RNAseq|df"
pattern <- "(?i)[hc]|p"
# remainder <-
  missing_specimenID %>% filter(str_detect(specimenID, pattern, negate = TRUE))
View(remainder)



# DATA 

# Find individualID + specimenID in data that are missing from metadata
# Immunoassay (Immunofluorescence) - Processed
immuno_1 <-
  synGet("syn22049816",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
immuno_2 <-
  synGet("syn22049825",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
immuno_3 <-
  synGet("syn22049817",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
immuno_4 <-
  synGet("syn22049819",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
# Immunoassay (Electrochemiluminescence)
immuno_5 <-
    synGet("syn22101766",
           downloadLocation = "temp",
           ifcollision = "overwrite.local"
    )
immuno_6 <-
    synGet("syn22101767",
           downloadLocation = "temp",
           ifcollision = "overwrite.local"
    )
immuno_7 <-
    synGet("syn22101772",
           downloadLocation = "temp",
           ifcollision = "overwrite.local"
    )
imm_1 <- immuno_1$path %>%
  read_csv()# %>%
  select(1, 2)
imm_2 <- immuno_2$path %>%
  read_csv() %>%
  select(1, 2)
imm_3 <- immuno_3$path %>%
  read_csv() %>%
  select(1, 2)
imm_4 <- immuno_4$path %>%
  read_csv() %>%
  select(1, 2)
imm_5 <- immuno_5$path %>%
  read_csv() %>%
  select(1, 2)
imm_6 <- immuno_6$path %>%
  read_csv() %>%
  select(1, 2)
imm_7 <- immuno_7$path %>%
  read_csv() #%>%
  select(1, 2)
imm_id <- bind_rows(list(imm_1, imm_2, imm_3, imm_4, imm_5, imm_6, imm_7))

immuno_individuals <- imm_id$IndividualID %>%
  unique() %>%
  sort()
immuno_specimens <- imm_id$SpecimenID %>%
  unique() %>%
  sort()
immuno_individuals_missing <- immuno_individuals[!immuno_individuals %in% ind_v12$individualID]
immuno_specimens_missing <- immuno_specimens[!immuno_specimens %in% bio_v08$specimenID] %>% as_tibble()
immuno_specimens_missing %>% write_csv("immunoassay_specimens_missing_from_biospecimen_metadata.csv")

# my hope is that ^^^ matches up with Sharla's findings
sharla <- read_csv("pathology_specimens_missing_from_biospecimen_metadata.csv")

immuno_specimens_missing %in% sharla$specimen_id
immuno_specimens_missing[!immuno_specimens_missing %in% sharla$specimen_id]

immuno_specimens_missing %>%
  as_tibble() %>%
  filter(str_detect(value, "[hc]", negate = FALSE))
immuno_specimens_missing %>%
  mutate(specimen_identifier = str_extract(value, "[hc]")) %>%
  filter(str_detect(value, "[hc]",
    negate = FALSE
  ))

# duplicate and/or inconsistent rows
bio_v08 %>% filter(individualID == "299")
bio_v08 %>% filter(individualID == "480")

# Mismatch between suffix and tissue
bio_v08 %>%
  select(1, 2, 5) %>%
  mutate(individualID = as.character(individualID)) %>% 
  mutate(specimen_identifier = str_extract(specimenID, "[ch]")) %>%
  mutate(tissue_identifier = substr(tissue, 1, 1)) %>%
  mutate(match = specimen_identifier == tissue_identifier) %>%
  arrange(specimen_identifier, specimenID) %>%
  filter(match == FALSE) %>%
  group_by(specimen_identifier)


# 2022-03-25 - Giedre asked about beahvioral data. Want to make sure we have all of the
# individuals in the behavioral files captured in the individual metadata file. Also,
# we want to know if there are also associated biospecimens in gene expression files
# where we would expect specimenID to be captured.

behav_1 <- synGet("syn22101758", downloadLocation = "temp", ifcollision = "overwrite.local")
behav_2 <- synGet("syn22101733", downloadLocation = "temp", ifcollision = "overwrite.local")
behav_3 <- synGet("syn22101734", downloadLocation = "temp", ifcollision = "overwrite.local")
behav_4 <- synGet("syn22101736", downloadLocation = "temp", ifcollision = "overwrite.local")
beh_1 <- behav_1$path %>%
  read_csv() %>%
  select(individualID)
beh_2 <- behav_2$path %>%
  read_csv() %>%
  select(individualID)
beh_3 <- behav_3$path %>%
  read_csv() %>%
  select(individualID)
beh_4 <- behav_4$path %>%
  read_csv() %>%
  select(individualID)
beh_id <- bind_rows(list(beh_1, beh_2, beh_3, beh_4))

beh_individuals <- beh_id$individualID %>%
  unique() %>%
  sort()
summary(beh_individuals)

table(beh_individuals %in% ind_v12$individualID)
table(beh_individuals %in% bio_v08$individualID)


beh_individuals[!beh_individuals %in% ind_v12$individualID]
beh_individuals[!beh_individuals %in% bio_v08$individualID]

# immuno_specimens_missing <- 
# immuno_specimens[!immuno_specimens %in% ] %>% as_tibble()
# immuno_specimens_missing %>% write_csv("immunoassay_specimens_missing_from_biospecimen_metadata.csv")



# 2022-03-30 - Inspect revised biospecimen file ----------------------------------------
biospecimen_new <-
  synGet(
    "syn28559120",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
bio_new <- biospecimen_new$path %>% read_csv()

# Compare metadata frames
dplyr::all_equal(bio_new, bio_v08)
janitor::compare_df_cols(bio_new, bio_v08)

previously_missing_indidividualID <- c(4199, 4204, 4208, 4209, 4242, 4244, 4255, 4264, 4265, 4266, 4281, 4503)
previously_missing_indidividualID %in% bio_new$individualID

# Mismatch between suffix and tissue
bio_new %>%
  select(1, 2, 5) %>%
  mutate(individualID = as.character(individualID)) %>% 
  mutate(specimen_identifier = tolower(str_extract(bio_new$specimenID, "(?i)[chp]"))) %>%
  mutate(tissue_identifier = substr(tissue, 1, 1)) %>%
  mutate(match = specimen_identifier == tissue_identifier) %>%
  arrange(specimen_identifier, specimenID) %>%
  filter(match == FALSE) %>%
  group_by(specimen_identifier) 

# duplicate and/or inconsistent rows
bio_new %>% filter(individualID==480)# %>% select(1,2,5)
bio_new %>% filter(individualID == 534)




individual_new <-
  synGet("syn28559121",
    downloadLocation = "temp",
    ifcollision = "overwrite.local"
  )
ind_new <- individual_new$path %>% read_csv()

all_equal(ind_new, ind_v12)
janitor::compare_df_cols(ind_new, ind_v12)
