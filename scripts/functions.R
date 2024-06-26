# functions.R

# Load required libraries
library(tidyverse)
library(synapser)
library(synapserutils)
library(yaml)
library(purrr)  # For functional programming

# Function to read the study configuration file
read_study_config <- function(config_path) {
  config <- yaml::read_yaml(config_path)
  return(config)
}

# Function to convert xlsx to csv if the csv does not exist
convert_if_not_exists <- function(input_path) {
  output_path <- sub("\\.xlsx?$", ".csv", input_path)
  if (!file.exists(output_path)) {
    convert_xlsx_to_csv(input_path)  # Assumes convert_xlsx_to_csv is a predefined function
  } else {
    message("Output file already exists: ", output_path)
  }
}

# Function to download files from Synapse without overwriting existing files
download_synapse_files <- function(folder_id, study_name, base_path = "modelad/data") {
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

# Function to rename files if needed
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
get_file_names_in_folder <- function(folder_id) {
  target_files <- synGetChildren(folder_id)
  target_file_names <- map_chr(target_files$asList(), "name")
  return(target_file_names)
}

# Function to move files to a target folder
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

# Function to set annotations on a Synapse entity
set_annotations <- function(entity_id, annotations_list) {
  # Retrieve the entity
  entity <- synGet(entity_id)

  # Get current annotations
  annotations <- synGetAnnotations(entity_id)

  # Update annotations
  annotations <- modifyList(annotations, annotations_list)

  # Set the updated annotations
  synSetAnnotations(entity_id, annotations)

  message("Set annotations for entity ID: ", entity_id)
}
