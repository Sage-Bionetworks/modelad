library(tidyverse)
library(synapser)
library(synapserutils)
library(janitor)
library(furrr)
# source("functions/coalesce_join.R")
synLogin()
# https://sagebionetworks.jira.com/browse/ADEL-170

# Set up variables
consortium <- "MODEL-AD"

grant <- "U54AG054349"
study_name <- "UCI_3xTg-AD"
version <- "2023-08-14"
study_id <- "syn22964685"
staging_id <- "syn22964692"
# data_id <- ""
modelad_annotations = "syn51036997"

# Create a temporary directory
tmp <- file.path(getwd(), consortium, "tmp", study_name)
dir.create(tmp, recursive = TRUE)


# 1. Move files from Staging to Data
# id_list <- c(
#   'syn29659261',
#   'syn29664267',
#   'syn29662399',
#   'syn29655913',
#   'syn29660762') %>% as.list()
# 
# target_id <- 'syn25812567'
# 
# furrr::future_walk(id_list, ~synMove(.x, target_id))

# 2. Update annotations
column_list <- c(
  # Identifiers
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "microchipID", columnType = "STRING"),
  Column(name = "birthID", columnType = "STRING"),
  Column(name = "matingID", columnType = "STRING")
  #,
  # # Study
  # Column(name = "study", columnType = "STRING"),
  # Column(name = "grant", columnType = "STRING"),
  # Column(name = "consortium", columnType = "STRING")#,
  # # Biological
  # Column(name = "species", columnType = "STRING"),
  # Column(name = "tissue", columnType = "STRING"),
  # Column(name = "organ", columnType = "STRING"),
  # Column(name = "modelSystemName", columnType = "STRING"),
  # Column(name = "modelSystemType", columnType = "STRING"),
  # Column(name = "genotype", columnType = "STRING"),
  # Column(name = "genotypeBackground", columnType = "STRING"),
  # Column(name = "individualCommonGenotype", columnType = "STRING"),
  # Column(name = "individualIdSource", columnType = "STRING"),
  # Column(name = "materialOrigin", columnType = "STRING"),
  # Column(name = "ageDeath", columnType = "DOUBLE"),
  # Column(name = "ageDeathUnits", columnType = "STRING"),
  # Column(name = "generation", columnType = "STRING"),
  # Column(name = "bedding", columnType = "STRING"),
  # Column(name = "waterpH", columnType = "DOUBLE"),
  # Column(name = "brainWeight", columnType = "DOUBLE"),
  # Column(name = "rodentWeight", columnType = "DOUBLE"),
  # Column(name = "rodentDiet", columnType = "STRING"),
  # Column(name = "room", columnType = "STRING"),
  #  # Experimental Information
  # Column(name = "officialName", columnType = "STRING", maximumSize = "100"),
  # Column(name = "assay", columnType = "STRING"),
  # Column(name = "treatmentType", columnType = "STRING"),
  # Column(name = "dateBirth", columnType = "STRING"),
  # Column(name = "dateDeath", columnType = "DATE"),
  # Column(name = "resourceType", columnType = "STRING"),
  # Column(name = "metadataType", columnType = "STRING"),
  # Column(name = "dataType", columnType = "STRING"),
  # Column(name = "fileFormat", columnType = "STRING"),
  # Column(name = "stockNumber", columnType = "STRING"),
  # Column(name = "isModelSystem", columnType = "BOOLEAN"),
  # Column(name = "isMultiSpecimen", columnType = "BOOLEAN")
)


# Create a fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = modelad_annotations,  
  scopes = study_id,
  includeEntityTypes=c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = column_list
)
schema <- synStore(schema)

# 2023-08-15 There is a problem with readLength column be duplicated. One includes strings, and another type includes integer values. The integer values were 43

'''
synGet(entity, version=NULL, 
       downloadFile=NULL, downloadLocation=NULL, 
       followLink=NULL, ifcollision=NULL, limitSearch=NULL)
'''






entity <- "syn23532197"
synGet(entity, 
       downloadFile=TRUE, downloadLocation=tmp, 
       followLink=FALSE, ifcollision="keep.local")

file_list <- c(
  'syn23532197',
  'syn23532198',
  'syn23532199',
  'syn25921758') %>% as.list()

furrr::future_walk(file_list, ~synGet(.x, 
                                      downloadFile=TRUE, downloadLocation=tmp, 
                                      followLink=FALSE, ifcollision="keep.local"))



# drop_column_list <- c(
#   # Identifiers
#   Column(name = "description", columnType = "STRING"),
#   Column(name = "createdBy", columnType = "DATE"),
#   Column(name = "createdBy", columnType = "DATE"),
#   Column(name = "parentId", columnType = "STRING")#,
#   # Column(name = "microchipID", columnType = "STRING"),
#   # Column(name = "birthID", columnType = "STRING"),
#   # Column(name = "matingID", columnType = "STRING"),
# )
# # Remove the createdOn and modifiedOn columns from the schema
# schema$removeColumn(drop_column_list)

# Try to store the schema  


 
fileview_id <- schema$properties$id

# Pull existing annotations from Synapse
query <-
  synTableQuery(paste("SELECT * FROM", fileview_id), resultsAs="csv")$filepath %>%
  read_csv()

query %>% 
  select(id, name, study, resourceType, metadataType, dataType )%>% 
  filter(str_detect(name, "metadata"))




# # Pull existing asnnotations from Synapse
# df <-
#   synTableQuery(paste("SELECT * FROM", schema$properties$id))$filepath %>%
#   read_csv()
#   #select(1,4,5)



