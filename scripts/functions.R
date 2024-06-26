# Load required libraries
library(tidyverse)
library(synapser)
library(synapserutils)
library(yaml)
library(purrr)

# Configuration Functions

# Function to read the study configuration file
# Pseudocode:
# 1. Check if the config file exists and is readable
# 2. Parse the YAML file
# 3. Return the parsed configuration
read_study_config <- function(config_path) {
  if (!file.exists(config_path)) {
    stop("Configuration file does not exist: ", config_path)
  }
  config <- yaml::read_yaml(config_path)
  return(config)
}

# Input/Output Functions

# Function to convert xlsx to csv if the csv does not exist
# Pseudocode:
# 1. Check if the corresponding CSV file exists
# 2. If not, call the convert_xlsx_to_csv function
# 3. Ensure convert_xlsx_to_csv is defined and converts correctly
convert_if_not_exists <- function(input_path) {
  output_path <- sub("\\.xlsx?$", ".csv", input_path)
  if (!file.exists(output_path)) {
    if (!exists("convert_xlsx_to_csv")) {
      stop("Function convert_xlsx_to_csv is not defined")
    }
    convert_xlsx_to_csv(input_path)
  } else {
    message("Output file already exists: ", output_path)
  }
}

# Function to download files from Synapse without overwriting existing files
# Pseudocode:
# 1. Create the local download path if it doesn't exist
# 2. List existing files in the download path
# 3. Download files from Synapse using syncFromSynapse
# 4. List new files downloaded
# 5. Handle any errors that occur during download
download_synapse_files <- function(folder_id, study_name, base_path = "data") {
  download_path <- file.path(base_path, study_name)
  if (!dir.exists(download_path)) {
    dir.create(download_path, recursive = TRUE)
  }

  existing_files <- list.files(download_path, recursive = TRUE)

  tryCatch({
    synapserutils::syncFromSynapse(folder_id, path = download_path, ifcollision = "keep.local")
    new_files <- setdiff(list.files(download_path, recursive = TRUE), existing_files)
    if (length(new_files) == 0) {
      message("No new files were downloaded from folder ID: ", folder_id)
    } else {
      message("Files downloaded successfully from folder ID: ", folder_id, " to ", download_path)
      message("New files: ", paste(new_files, collapse = ", "))
    }
  }, error = function(e) {
    stop("Failed to download files from Synapse: ", e$message)
  })
}

# File Operations Functions

# Function to rename files if needed
# Pseudocode:
# 1. Retrieve the file from Synapse
# 2. Check if the file needs to be renamed
# 3. Rename the file and update Synapse if needed
rename_file_if_needed <- function(file_id, new_name) {
  file <- synGet(file_id)
  if (file$name != new_name) {
    file$name <- new_name
    file <- synStore(file, forceVersion = FALSE)
    message("File renamed to: ", new_name)
  } else {
    message("File already has the desired name: ", new_name)
  }
}

# Function to get all file names in a target folder
# Pseudocode:
# 1. Retrieve the list of files in the specified folder from Synapse
# 2. Return the list of file names
get_file_names_in_folder <- function(folder_id) {
  target_files <- synGetChildren(folder_id)
  target_file_names <- map_chr(target_files$asList(), "name")
  return(target_file_names)
}

# Function to move files to a target folder
# Pseudocode:
# 1. Retrieve the file from Synapse
# 2. Check if the file already exists in the target folder
# 3. Move the file to the target folder if it doesn't exist there
# 4. Update Synapse with the new parent folder ID
move_file_to_folder <- function(file_id, target_folder_id) {
  target_file_names <- get_file_names_in_folder(target_folder_id)
  file <- synGet(file_id)
  if (file$name %in% target_file_names) {
    message("File already exists in target folder: ", file$name)
  } else {
    file$parentId <- target_folder_id
    file <- synStore(file, forceVersion = FALSE)
    message("File moved to folder ID: ", target_folder_id)
  }
}

# Annotations Functions

# Function to set annotations on a Synapse entity
# Pseudocode:
# 1. Retrieve the entity from Synapse
# 2. Print the entity for debugging
# 3. Update the entity's annotations
# 4. Store the updated entity in Synapse
set_annotations <- function(entity_id, annotations_list) {
  # Step 1: Retrieve the entity from Synapse
  entity <- synGet(entity_id)

  # Step 2: Print the entity for debugging
  print(entity)

  # Step 3: Update the entity's annotations
  entity$annotations <- annotations_list

  # Step 4: Store the updated entity in Synapse
  entity <- synStore(entity)

  message("Set annotations for entity ID: ", entity_id)
}

# Example usage of set_annotations function
# Ensure you have the Synapse login credentials set up properly
# synLogin("username", "password")

# Example call
# set_annotations("syn12345", list(new_annotation_key = "new_annotation_value"))

