library(tidyverse)
library(synapser)

synLogin()

# Set up variables
consortium <- "MODEL-AD"
grant <- ""
study_name <- "Jax.IU.Pitt_LOAD1.PrimaryScreen"
study_id <- "syn21595258"
staging_id <- ""
data_id <- ""
fileviewProject_id <- "syn51036997"

minimum_annotation_set <- c(
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING")
)

# Configure fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = fileviewProject_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = FALSE,
  addAnnotationColumns = FALSE,
  columns = minimum_annotation_set
)
# Upload schema
schema <- synStore(schema)


# Pull existing annotations from Synapse
df <-
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$filepath %>%
  read_csv() 

df$study <- "Jax.IU.Pitt_LOAD1.PrimaryScreen"

# Push annotations to Synapse
synStore(Table(schema$properties$id, df))
