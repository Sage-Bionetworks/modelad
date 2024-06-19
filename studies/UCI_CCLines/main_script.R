# Load necessary libraries
library(synapser)
library(dplyr)
library(readr)
library(janitor)
library(yaml)

# Log in to Synapse
synLogin()

# Define the path to your configuration file
config_path <- "modelad/studies/UCI_CCLines/study_config.yaml"

# Read the configuration file
config <- yaml::read_yaml(config_path)

# Generate the name for the file view
name <- paste(config$program, config$studyID, "View", sep = "_")

# Extract Synapse IDs and other parameters from the configuration file
parent <- config$parentID
scope <- config$scopeID

# Ensure scope is a list of Synapse IDs
if (!is.list(scope)) {
  scope <- as.list(scope)
}

# Function to create a fileview schema
create_fileview_schema <- function(name, parent, scope) {
  schema <- EntityViewSchema(
    name = name,
    parent = parent,
    scopes = scope,
    includeEntityTypes = list(EntityViewType$FILE),
    addDefaultViewColumns = FALSE,
    addAnnotationColumns = TRUE
  )
  fileview <- synStore(schema)
  return(fileview$properties$id)
}

# Function to query a fileview and return a dataframe
query_fileview <- function(fileviewId) {
  query_result <- synTableQuery(paste("SELECT * FROM", fileviewId))
  df <- read_csv(query_result$filepath) %>%
    clean_names()
  return(df)
}

# Create fileview schema and capture the ID
fileview_id <- create_fileview_schema(name, parent, scope)

# Query the fileview and read data into a tibble
fileview_data <- query_fileview(fileview_id)

# Display the first few rows of the data
print(head(fileview_data))
