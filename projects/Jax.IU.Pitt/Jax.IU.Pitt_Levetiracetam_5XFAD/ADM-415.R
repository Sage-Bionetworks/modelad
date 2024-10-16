# https://sagebionetworks.jira.com/browse/ADM-415

# some files from the Jax Levetiracetam study were mistakenly annotated with modelSystemType = "5XFAD"
# Change modelSystemType = "animal"
# modelSystemName = 5XFAD
# previous work MODEL-AD/2023-03-10-Jax.IU.Pitt_Levetiracetam_5XFAD.R

library(synapser)
library(tidyverse)
synLogin()

fileviewProject_id <- "syn51036997"
study_id <- "syn21784897"
study_name <- "Jax.IU.Pitt_Levetiracetam_5XFAD"

columns <- c(
  Column(name = "individualID", columnType = "STRING", required = TRUE),
  Column(name = "specimenID", columnType = "STRING", required = TRUE),
  Column(name = "resourceType", columnType = "STRING", required = TRUE),
  Column(name = "metadataType", columnType = "STRING", required = TRUE),
  Column(name = "assay", columnType = "STRING", required = TRUE),
  Column(name = "dataType", columnType = "STRING", required = TRUE),
  Column(name = "fileFormat", columnType = "STRING", required = TRUE),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN", required = TRUE),
  Column(name = "isModelSystem", columnType = "BOOLEAN", required = TRUE),
  Column(name = "grant", columnType = "STRING", required = TRUE),
  Column(name = "consortium", columnType = "STRING", required = TRUE),
  Column(name = "study", columnType = "STRING", required = TRUE),
  Column(name = "modelSystemName", columnType = "STRING"), 
  Column(name = "modelSystemType", columnType = "STRING"), 
  Column(name = "organ", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"), 
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING")
)

# Configure fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = fileviewProject_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = columns
)
# Upload schema
schema <- synStore(schema)

# Pull annotations from Synapse and convert to a tibble
notes <- synTableQuery(paste("SELECT * FROM", schema$properties$id))$asDataFrame() %>% 
  as_tibble()

# Update modelSystemType (consolidated and more readable)
notes$modelSystemType <- case_when(
  notes$modelSystemType == "5XFAD" ~ "animal",
  is.na(notes$modelSystemType) | notes$modelSystemType == "" ~ "animal",
  TRUE ~ notes$modelSystemType  # Keep original values otherwise
)

# Update treatmentType
notes$treatmentType <- ifelse(notes$treatmentType == "" | is.na(notes$treatmentType),
                              "levetiracetam", 
                              notes$treatmentType)

# Upload annotations to Synapse
synStore(Table(schema$properties$id, notes))
