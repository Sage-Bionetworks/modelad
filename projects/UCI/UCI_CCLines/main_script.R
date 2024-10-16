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

# https://r-docs.synapse.org/reference/EntityViewSchema.html
#
# EntityViewSchema(name=NULL, columns=NULL, parent=NULL, scopes=NULL, type=NULL, includeEntityTypes=NULL, addDefaultViewColumns=TRUE, addAnnotationColumns=TRUE, ignoredAnnotationColumnNames=list(), properties=NULL, annotations=NULL)
#
# if (FALSE) {
#   project_or_folder <- synGet("syn123")
#   schema <- EntityViewSchema(name='MyFileView', parent=project, scopes=c(project_or_folder$properties$id, 'syn456'), includeEntityTypes=c(EntityViewType$FILE, EntityViewType$FOLDER))
#   schema <- synStore(schema)
# }


# Function to create a fileview schema
create_fileview_schema <- function(name, parent, scope) {
  # Define columns to include, ensuring no duplicates
  # columns <- list(
  #   Column(name = "test1", columnType = "STRING"),
  #   Column(name = "test2", columnType = "STRING")
  #   # Add other columns as necessary
  # )

  # Create the schema for the EntityView
  schema <- EntityViewSchema(
    name = name,
    parent = parent,
    scopes = scope,
    includeEntityTypes = c(EntityViewType$FOLDER)#,
    # addDefaultViewColumns = FALSE,
    # addAnnotationColumns = TRUE,
    # columns = columns
  )

  # Store the schema and return the file view ID
  fileview <- synStore(schema)
  return(fileview$properties$id)
}

# Create fileview schema and capture the ID
fileview_id <- create_fileview_schema(name, parent, scope)

# create a handy URL link to view fileview_id in browser
# https://www.synapse.org/Synapse:syn61344016/tables/
# https://staging.adknowledgeportal.synapse.org/Explore/Studies/DetailsPage/StudyDetails?Study=syn51713891

# Function tof query a fileview and return a dataframe
query_fileview <- function(fileviewId, num_rows = 20) {
  # Construct the query string
  query_string <- paste("SELECT * FROM", fileviewId)

  # Perform the query
  query_result <- synTableQuery(query_string, resultsAs = "csv")

  # Read the CSV file into a dataframe and clean column names
  df <- read_csv(query_result$filepath) %>%
    clean_names() %>%
    head(num_rows)  # Limit the number of rows returned

  return(df)
}

# Query the fileview and read data into a tibble
fileview_data <- query_fileview(fileview_id, num_rows = 30)  # Specify the number of rows to display

# Display the first few rows of the data
print(head(fileview_data))
brav