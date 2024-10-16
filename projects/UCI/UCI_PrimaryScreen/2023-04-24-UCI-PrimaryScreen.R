library(tidyverse)
library(synapser)
library(janitor)
synLogin()

consortium <- "MODEL-AD"
grant <- "U54AG054349"
study_name <- "UCI_PrimaryScreen"
version <- "2023-04-24"

# Synapse folders
study_id <- "syn25316706"
staging_id <- "syn25316709"
individual_id <- "syn25872020"
individual_id_staged <- "syn51248109"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp", study_name)

ind <- synGet(individual_id, version = 2,
              downloadLocation = file.path(tmp, "extant"), 
              ifcollision = "overwrite.local")$path %>% read_csv()

ind_staged <- synGet(individual_id, version = 3, # individual_id_staged,
              downloadLocation = file.path(tmp, "staging"),
              ifcollision = "overwrite.local")$path %>% read_csv()


# Clean up column names and remove empty columns
ind_staged <- rename(ind_staged, climbID = "Climb_Identifier")
ind_staged <- rename(ind_staged, microchipID = "Microchip Number")
ind_staged <- rename(ind_staged, rodentDiet = "Diet")

ind_staged %<>%
  clean_names(case = "lower_camel") %>%
  rename_with(~gsub("Id$", "ID", .), ends_with("Id"))

ind_staged[ind_staged == "NA"] <- NA
ind_staged <- ind_staged %>% janitor::remove_empty("cols")
ind_staged %>% colnames() %>% sort()

write_csv(ind_staged, file.path(tmp, "UCI_PrimaryScreen_individual_metadata.csv"))

ind_staged %>% select(individualCommonGenotype) %>% unique

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
  Column(name = "individualIdSource", columnType = "STRING"),
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
  Column(name = "genotypeBackground", columnType = "STRING"),
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

# notes <- results %>% select(1:5,22:23)
notes_to_push <- results %>%
  left_join(ind_staged, by = "individualID", multiple = "all") %>% 
  janitor::remove_empty(c("cols","rows")) %>%
  mutate(modelSystemName = coalesce(modelSystemName.x, modelSystemName.y),
         sex = coalesce(sex.x, sex.y),
         species = coalesce(species.x, species.y)) %>% 
  select(-matches(".*\\.(x|y)$"))

# Reduce annotations to necessary columns
notes_to_push %>% select(42:48) %>% colnames
  # select(-matches(c("room", "currentLocationPath","animalStatus","exit")
# Push new annotations to Synapse
synStore(Table(schema$properties$id, notes_to_push %>% select(-c(42:51))))
  
