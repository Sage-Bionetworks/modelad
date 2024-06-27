# Load required libraries
library(tidyverse)
library(synapser)
library(yaml)
library(stringr)

# Function to read the study configuration file
read_study_config <- function(config_path) {
  yaml::read_yaml(config_path)
}

# Function to set annotations on a Synapse entity
set_annotations <- function(entity_id, annotations_list) {
  entity <- synGet(entity_id)
  entity$annotations <- annotations_list
  synStore(entity)
  message("Set annotations for entity ID: ", entity_id)
}

# Function to download data based on configuration
download_data <- function(synID, download_path) {
  if (!dir.exists(download_path)) {
    dir.create(download_path, recursive = TRUE)
  }
  synapser::synGet(synID, downloadLocation = download_path)
}

# Function to move files to a target folder
move_file_to_folder <- function(file_id, target_folder_id) {
  target_file_names <- get_file_names_in_folder(target_folder_id)
  file <- synGet(file_id)
  if (file$name %in% target_file_names) {
    message("File already exists in target folder: ", file$name)
  } else {
    file$parentId <- target_folder_id
    synStore(file, forceVersion = FALSE)
    message("File moved to folder ID: ", target_folder_id)
  }
}

# Function to rename files if needed
rename_file_if_needed <- function(file_id, new_name) {
  file <- synGet(file_id)
  if (file$name != new_name) {
    file$name <- new_name
    synStore(file, forceVersion = FALSE)
    message("File renamed to: ", new_name)
  } else {
    message("File already has the desired name: ", new_name)
  }
}

# Function to get all file names in a target folder
get_file_names_in_folder <- function(folder_id) {
  target_files <- synGetChildren(folder_id)
  map_chr(target_files$asList(), "name")
}

# Function to update Synapse wiki page
update_wiki_page <- function(synapse_id, wiki_id, new_content) {
  wiki <- synGetWiki(owner = synapse_id, wikiId = wiki_id)
  wiki$markdown <- new_content
  synStore(wiki)
  message("Wiki page updated successfully: ", wiki_id)
}

# Function to clean formatting in markdown content
clean_formatting <- function(markdown_content) {
  clean_content <- str_replace_all(markdown_content, "<em1[^>]*>", "")
  str_replace_all(clean_content, "<em>|</em>", "")
}

# Function to convert a DOCX file to Markdown and update the Synapse wiki
convert_and_update_wiki <- function(file_name, file_mappings, dry_run = TRUE) {
  wiki_project <- file_mappings[[file_name]]
  doc_path <- file.path("modelad/data/docs", file_name)
  output_file <- sub(".docx$", ".md", doc_path)
  
  system(paste("pandoc -f docx -t markdown_strict --wrap=none '", doc_path, "' -o '", output_file, "'"))
  
  markdown_content <- read_file(output_file)
  cleaned_content <- clean_formatting(markdown_content)
  write_file(cleaned_content, output_file)
  
  if (dry_run) {
    message("Dry run: Wiki update prepared for file: ", file_name)
    return()
  }
  
  wiki_object <- tryCatch(synGetWiki(wiki_project), error = function(e) NULL)
  existing_content <- if (!is.null(wiki_object)) wiki_object$markdown else ""
  
  if (existing_content == "") {
    wiki <- Wiki(owner = wiki_project, markdownFile = output_file)
    synStore(wiki)
    message("Wiki updated for project: ", wiki_project)
  } else {
    message("Wiki already has content. Skipping update for project: ", wiki_project)
  }
}

# Example usage of the read_study_config function
example_usage_read_study_config <- function(config_path) {
  config <- read_study_config(config_path)
  
  # Accessing specific elements
  adelID <- config$adelID
  studyName <- config$studyName
  synIDs <- config$synIDs
  metadata <- config$metadata
  proteomics_raw_data <- config$assays$Proteomics$raw_data
  
  # Print values for verification
  message("ADEL ID: ", adelID)
  message("Study Name: ", studyName)
  message("Synapse Study ID: ", synIDs$study)
  message("Proteomics Raw Data Synapse ID: ", proteomics_raw_data)
}

# Example call to demonstrate usage
# example_usage_read_study_config("path/to/study_config.yml")
