library(tidyverse)
library(synapser)
library(janitor)
synLogin()

consortium <- "MODEL-AD"
grant <- "U54AG054349"
study_name <- "UCI-hAbeta-KI"
version <- "2023-04-11"

# Synapse folders
study_id <- "syn18634479"
staging_id <- "syn18880210"
individual_id <- "syn18880212"
biospecimen_id <- "syn18818785"
individual_id_staged <- "syn51248038"
biospecimen_id_staged <- "syn51248037"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp", study_name)

ind <- synGet(individual_id, version = 7,
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

bio <- synGet(biospecimen_id, version = 3,
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

# ind_staged <- synGet(individual_id_staged,
#               downloadLocation = file.path(tmp, "staging"), 
#               ifcollision = "overwrite.local")$path %>% read_csv()
# 
# bio_staged <- synGet(biospecimen_id_staged,
#               downloadLocation = file.path(tmp, "staging"), 
#               ifcollision = "overwrite.local")$path %>% read_csv()
# 
# 
# 
# # Clean up column names and remove empty columns
# ind_staged <- rename(ind_staged, climbID = "Climb_Identifier")
# ind_staged <- rename(ind_staged, microchipID = "Microchip Number")
# ind_staged <- rename(ind_staged, rodentDiet = "Diet")
# 
# ind_staged %>% colnames()
# ind_staged %<>% 
#   clean_names(case = "lower_camel") %>% 
#   rename_with(~gsub("Id$", "ID", .), ends_with("Id"))
# 
# 
# ind_staged[ind_staged == "NA"] <- NA
# ind_staged <- ind_staged %>% janitor::remove_empty("cols")
# ind_staged %>% colnames() %>% sort()
# 
# write_csv(ind_staged, file.path(tmp, "UCI_hABKI_individual_metadata.csv"))


# Create fileview
project <- Project("MODEL-AD-Annotations") %>% synStore()
keys <- c(
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "dateDeath", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "officialName", columnType = "STRING"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "waterpH", columnType = "INTEGER"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "INTEGER"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "ageBirth", columnType = "INTEGER"),
  Column(name = "individualCommonGenotype", columnType = "STRING")
  )

schema <-
  EntityViewSchema(
    name = study_name,
    parent = project$properties$id,
    scopes = study_id,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE, 
    columns = keys) %>% synStore() 

# Pull existing annotations from Synapse
query <- paste("SELECT * FROM", schema$properties$id)
results <- synTableQuery(query, resultsAs="csv")$filepath %>% read_csv()
# results <- results %>% select(23:40)
results[results == "NA"] <- NA
results <- results %>% janitor::remove_empty("cols")


notes <- results %>% select(1:5,22:23)
notes_to_push <- notes  %>% 
  left_join(ind, by = "individualID", multiple = "all") %>% 
  left_join(bio, by = c("individualID","specimenID"), multiple = "all") %>% 
  # left_join(., as2, by = c("specimenID", "assay"))
  coalesce() %>% 
  janitor::remove_empty(c("cols","rows")) %>% 
  select(-contains(".x"), -contains(".y")) %>% 
  # select(-genotype,-genotypeBackground,-litter,-matingID) %>% 
  select(1:10,15:16,17:19,25,27:33)


# Push new annotations to Synapse
synStore(Table(schema$properties$id, notes_to_push))

