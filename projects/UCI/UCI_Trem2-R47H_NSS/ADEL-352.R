# Load necessary libraries
library(dplyr)
library(purrr)
library(tibble)
library(synapser)
library(synapserutils)
library(readr)
library(readxl)
library(janitor)

# Log in to Synapse
synLogin()

# Load utility functions
source("modelad/code/curation_utils.R")

# Load configuration and extract key values
base_path <- file.path("modelad", "projects", "UCI_Trem2-R47H_NSS")
config_path <- file.path(base_path, "study_config.yml")
config <- read_config(config_path)

parent_id <- config$study$ids$synapse$main
staging_id <- config$study$ids$synapse$staging
project_name <- config$study$name
scopes <- extract_synapse_ids(config$study$data)
metadata_id <- "syn26943953"

# Synchronize files from Synapse
files <- synapserutils::syncFromSynapse(metadata_id)

# Create a File View schema and store it
schema <- EntityViewSchema(
  name = project_name,
  parent = "syn2580853",  # Verify this is the correct parent ID
  scopes = scopes,
  includeEntityTypes = list(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = TRUE
) %>% synStore()

# Query the file view
query <- sprintf("SELECT * FROM %s", schema$properties$id)
notes <- synTableQuery(query)$asDataFrame() %>% as_tibble()

library(dplyr)
library(purrr)

# Process notes data frame
notes2 <- notes %>%
  mutate(across(c(consortium, grant, dataType, resourceType), ~ na_if(., ""))) %>%
  # Handle potential list columns and fill NAs with defaults
  mutate(
    consortium = coalesce(consortium, "MODEL-AD"),
    grant = coalesce(grant, "U54AG054349"),
    dataType = coalesce(dataType, "geneExpression"),
    resourceType = coalesce(resourceType, "experimentalData")
  )

# notes2 <-  notes2 %>% select(-isMultiSpecimen,-isModelSystem)
# Store the cleaned data frame in Synapse
synStore(Table(schema$properties$id, as.data.frame(notes2)))

str(notes2)
notes2 <- notes2 %>%
  mutate(across(where(is.factor), as.character)) %>%
  mutate(across(where(is.list), ~ map_chr(., ~ paste(.x, collapse = "; "))))

notes2[is.na(notes2)] <- ""

synStore(Table(schema$properties$id, as.data.frame(head(notes2, 10))))
existing_data <- synTableQuery(sprintf("SELECT * FROM %s", schema$properties$id))$asDataFrame()



