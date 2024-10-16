library(tidyverse)
library(synapser)
library(synapserutils)

# Goals: Test setting annotations programmatically.
# Create a generic Synapse annotation set for new files.

synLogin(silent = TRUE)
setwd("~/GitHub/sageCuration/2022-02-22-UCI_Trem2-R47H_NSS/")

# Create project
project <- Project("Rich-Annotations")
project <- synStore(project)

# Study folders
rna_seq <- "syn26944026"
immunoassay <- "syn26954638"
metadata <- "syn26943955"

annotation_cols <- c(
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "dataSubType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "individualIdSource", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "nucleicAcidSource", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "modelSystemType", columnType = "STRING")
)

# Create file view
view <- EntityViewSchema(
  name = "UCI_Trem2-R47H_NSS",
  parent = project$properties$id,
  scopes = c(metadata, rnaSeq, immunoassay),
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = TRUE,
  columns = annotation_cols
)
view <- synStore(view)

# Import view
data <-
  synTableQuery(paste("SELECT * FROM", view$properties$id))$asDataFrame() %>% as_tibble()
glimpse(data)
