# Load required libraries
library(synapser)
library(tidyverse)
library(yaml)

# Authenticate with Synapse
synLogin()

# Define the path to the study configuration file
config_path <- "modelad/studies/Jax.IU.Pitt_Verubecestat_5XFAD/study_config.yml"

# Check if the configuration file exists
if (!file.exists(config_path)) {
  stop("Configuration file not found: ", config_path)
}

# Read the study configuration from the YAML file
config <- yaml::read_yaml(config_path)

# Base URL for constructing full URLs for ADEL and ADM identifiers
base_url <- "https://sagebionetworks.jira.com/browse/"

# Construct full URLs for ADEL and ADM identifiers
adel_url <- paste0(base_url, config$study$adelID)
adm_url <- paste0(base_url, config$study$admID)

# Print the constructed URLs (for verification)
print(paste("ADEL URL:", adel_url))
print(paste("ADM URL:", adm_url))

# Extract relevant information from the configuration
target_folder_id <- config$study$studyID
metadata_general_id <- config$study$metadata$individual

# Create a list of all data_ids from config$study$assays content
data_ids <- unlist(lapply(config$study$assays, function(assay) assay$data))

# Define annotations to set
annotations_list <- list(
  contentType = "dataset",
  studyName = config$study$name,
  program = config$study$program
)

# Function to move files to the target folder
move_file_to_folder <- function(file_id, folder_id) {
  entity <- synGet(file_id)
  entity$parentId <- folder_id
  synStore(entity)
}

# Function to set annotations
set_annotations <- function(file_id, annotations) {
  synSetAnnotations(file_id, annotations)
}

# Function to move files to the target folder and set annotations
move_and_annotate <- function(data_id, target_folder_id, annotations_list) {
  move_file_to_folder(data_id, target_folder_id)
  set_annotations(data_id, annotations_list)
}

# Move files to the target folder and set annotations
walk(data_ids, ~ move_and_annotate(.x, target_folder_id, annotations_list))

# Move specific file to the target metadata folder
move_file_to_folder("syn52360061", metadata_general_id)

# Download the file view annotations from "Portal - Studies Table"
file_view_id <- "syn17083367"
file_view_annotations <- synTableQuery(paste("SELECT * FROM", file_view_id))$asDataFrame() %>%
  as_tibble()

# Filter annotations to include only the MODEL-AD consortium and the specific study
study_annotations <- file_view_annotations %>%
  filter(Program == "[\"MODEL-AD\"]", Study == config$study$name)

# Update study annotations with missing or mismatching information from the configuration
updated_annotations <- study_annotations %>%
  mutate(across(
    c(name, program, portal),
    ~ ifelse(is.na(.x) | .x != config$study[[cur_column()]], config$study[[cur_column()]], .x)
  ))

# Summarize and print changes
changes <- updated_annotations %>%
  summarise(across(everything(), ~ sum(. != study_annotations[[cur_column()]])))

print("Summary of changes:")
print(changes)

# Store the updated annotations back to Synapse
table <- synBuildTable("Updated Annotations", file_view_id, updated_annotations)
synStore(table)

message("Dataset curation completed successfully.")
