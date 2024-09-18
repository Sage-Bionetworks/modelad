library(tidyverse)
library(synapser)
library(janitor)
library(readxl)

# Set up variables
grant <- "U54AG054345"
consortium <- "MODEL-AD"
study_name <- "Jax.IU.Pitt_5XFAD"
version <- "2023-05-10"
study_id <- "syn21983020"
project_id <- "syn51036997"

# Create a temporary directory
tmp <- file.path(getwd(), "data-curation", consortium, "tmp", study_name)
dir.create(tmp, recursive = TRUE)

# Download the metadata
ind <- synGet("syn51356878",
              downloadLocation = file.path(tmp, "staging"), 
              ifcollision = "overwrite.local")

ind3 <- synGet("syn22103212", version = 3,
               downloadLocation = file.path(tmp, "v3"), 
               ifcollision = "overwrite.local")

# Read the data into R
ind <- read_excel(ind$path)
ind3 <- read_csv(ind3$path)

# Create a list of column names
column_list <- c(
  # Identifiers
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "microchipID", columnType = "STRING"),
  Column(name = "birthID", columnType = "STRING"),
  Column(name = "matingID", columnType = "STRING"),
  
  # Study
  Column(name = "study", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  
  # Biological
  Column(name = "species", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "genotypeBackground", columnType = "STRING"),
  Column(name = "individualCommonGenotype", columnType = "STRING"),
  Column(name = "individualIdSource", columnType = "STRING"),
  Column(name = "materialOrigin", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "DOUBLE"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "generation", columnType = "STRING"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "waterpH", columnType = "DOUBLE"),
  Column(name = "brainWeight", columnType = "DOUBLE"),
  Column(name = "rodentWeight", columnType = "DOUBLE"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "room", columnType = "STRING"),
  
  # Experimental Information
  Column(name = "officialName", columnType = "STRING", maximumSize = "100"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "dateDeath", columnType = "DATE"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN")
)

# Create a fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = project_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = column_list
)

# Try to store the schema
tryCatch({
  schema <- synStore(schema)
  fileview_id <- schema$properties$id
}, error = function(e) {
  stop(e)
})

# Pull existing annotations from Synapse
results <- 
  synTableQuery(paste("SELECT * FROM", fileview_id), resultsAs="csv")$filepath %>% 
  read_csv()

# Edit annotations
notes <- results %>%
  select(1, 3, 23) %>%
  left_join(ind, by = "individualID") %>%
  janitor::remove_empty("cols") #%>%
  # mutate(dateBirth = ymd(notes$dateBirth))

# Create a vector of column names to push
columns_to_push <- c(
  "ROW_ID",
  "ROW_ETAG",
  "individualID",
  # "specimenID",
  "climbID",
  "microchipID",
  "birthID",
  "matingID",
  # "study",
  # "grant",
  # "consortium",
  "species",
  # "tissue",
  # "organ",
  "modelSystemName",
  # "modelSystemType",
  "genotype",
  "genotypeBackground",
  "individualCommonGenotype",
  "individualIdSource",
  "materialOrigin",
  "ageDeath",
  "ageDeathUnits",
  "generation",
  "bedding",
  "waterpH",
  "brainWeight",
  "rodentWeight",
  "rodentDiet",
  "room",
  "officialName",
  # "assay",
  # "treatmentType",
  "dateBirth",
  # "dateDeath",
  # "resourceType",
  # "metadataType",
  # "dataType",
  # "fileFormat",
  "stockNumber"
  # "isModelSystem",
  # "isMultiSpecimen"
)

# Print the number of columns
print(length(columns_to_push))

# Push annotations to Synapse
synStore(Table(fileview_id, notes %>% select(all_of(columns_to_push))))

# Create a new data frame with the annotations
annotations <- notes %>%
  select(-ROW_ID, -ROW_ETAG)

# Write the annotations to a file
file_path <-  file.path(tmp, "Jax.IU.Pitt_5XFAD_individual_metadata.csv")
write.csv(annotations, file_path)

file <- File(file_path, parent = "syn21983022", dataFileHandleId ="syn22103212", versionLabel = 4)
filefile <- synStore(file)
