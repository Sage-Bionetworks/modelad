# Load required libraries and utility functions
library(synapser)
library(glue)
source("~/modelad/code/curation_utils.R")

# Authenticate with Synapse
synLogin()

# Define the view properties
file_view_name <- "ADKP - Model Datasets"
parent_id <- "syn2580853" # Parent folder ID for the view
scopes <- list("syn5550383") # Scope to the target Synapse folder

# Create the file view schema
schema <- create_file_view_schema(
    name = file_view_name,
    parent = parent_id,
    scopes = scopes,
    includeEntityTypes = c(EntityViewType$FOLDER),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE
)

# Store the file view on Synapse
schema <- synStore(schema)
# https://www.synapse.org/Synapse:syn63716987/tables/

# Retrieve the columns and keep only the first three
columns_list <- as.list(synGetColumns(schema$properties$id))
columns_to_keep <- columns_list[c(1,2,10,11,12,13,18,20,23,24)]

# Recreate the schema with the filtered columns
updated_schema <- create_file_view_schema(
  name = file_view_name,
  parent = parent_id,
  scopes = scopes,
  includeEntityTypes = c(EntityViewType$FOLDER),
  addDefaultViewColumns = FALSE,  # Set to FALSE now to avoid default columns
  addAnnotationColumns = FALSE,
  columns = columns_to_keep
)

# Store the updated schema with the modified columns
synStore(updated_schema)


# Define a query to filter by contentType and program
query <- glue("SELECT * FROM {schema$properties$id}")

# Query the file view
data <- synTableQuery(query)$asDataFrame() %>% as_tibble()
