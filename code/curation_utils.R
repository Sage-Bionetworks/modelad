# curation_utils.R: Utility functions for Synapse data curation tasks.
# Provides reusable functions for Synapse file handling, metadata management,
# data processing, file views, and Markdown management.

#' @title Synapse Data Curation Utilities
#' @description This file contains utility functions for various Synapse data curation tasks.
#' @details The functions are organized into the following categories:
#'   1. Synapse Authentication
#'   2. Synapse File Management
#'   3. Data Download and Processing
#'   4. File View and Wiki Management
#'   5. Snapshot Creation
#'   6. Markdown Management
#'   7. Folder Management
#' @author Your Name
#' @date Last Updated: YYYY-MM-DD

# Load necessary libraries
library(synapser)
library(dplyr)
library(readr)
library(readxl)
library(janitor)
library(stringr)
library(yaml)

### 1. Synapse Authentication ###

# Log in to Synapse
login_to_synapse <- function(silent = TRUE) {
  tryCatch({
    synLogin(silent = silent)
    message("Successfully logged in to Synapse.")
  }, error = function(e) {
    stop("Synapse login failed: ", e$message)
  })
}

### 2. Synapse File Management ###

# Add a local file to a Synapse folder or project
add_file_to_synapse <- function(file_path, parent_id) {
  if (!file.exists(file_path)) stop("File does not exist: ", file_path)
  tryCatch({
    synStore(File(path = file_path, parentId = parent_id))
    message("File added: ", basename(file_path), " to Synapse under ", parent_id)
  }, error = function(e) {
    stop("Failed to add file: ", e$message)
  })
}

# Move a Synapse entity (file/folder) to a new parent
move_entity_to_new_parent <- function(entity_id, new_parent_id) {
  tryCatch({
    entity <- synGet(entity_id, downloadFile = FALSE)
    if (entity$properties$parentId != new_parent_id) {
      entity$properties$parentId <- new_parent_id
      synStore(entity)
      message("Moved entity ", entity_id, " to new parent: ", new_parent_id)
    } else {
      message("Entity ", entity_id, " already in the target location.")
    }
  }, error = function(e) {
    stop("Failed to move entity: ", e$message)
  })
}

### 3. Data Download and Processing ###

# Download and preprocess metadata files from Synapse
download_and_preprocess <- function(syn_id, download_path = tempdir()) {
  if (!dir.exists(download_path)) dir.create(download_path, recursive = TRUE)
  tryCatch({
    file <- synGet(syn_id, downloadLocation = download_path)
    data <- read_csv(file$path) %>%
      clean_names() %>%
      remove_empty(c("rows", "cols"))
    return(data)
  }, error = function(e) {
    stop("Error downloading or processing file: ", e$message)
  })
}

### 4. File View and Wiki Management ###

# Create a file view for a Synapse project or study
create_file_view <- function(name, parent_id, scope_id) {
  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = list(scope_id),
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = FALSE
    )
    view_id <- synStore(view)$properties$id
    message("File view created: ", view_id)
    return(view_id)
  }, error = function(e) {
    stop("Failed to create file view: ", e$message)
  })
}

# Update a Synapse wiki page with new content
update_wiki_page <- function(synapse_id, wiki_id, new_content) {
  tryCatch({
    wiki <- synGetWiki(owner = synapse_id, wikiId = wiki_id)
    wiki$markdown <- new_content
    synStore(wiki)
    message("Wiki page updated: ", wiki_id)
  }, error = function(e) {
    stop("Failed to update wiki page: ", e$message)
  })
}

### 5. Snapshot Creation ###

# Create a snapshot for a Synapse file view (versioning)
create_snapshot <- function(file_view_id, version_label = NULL, snapshot_comment = NULL) {
  version_label <- ifelse(is.null(version_label), format(Sys.Date(), "%y.%m"), version_label)
  snapshot_comment <- ifelse(is.null(snapshot_comment), paste(version_label, "data release"), snapshot_comment)
  tryCatch({
    synCreateSnapshotVersion(
      table = file_view_id,
      comment = snapshot_comment,
      label = version_label,
      wait = TRUE
    )
    message("Snapshot created for: ", file_view_id, " with version: ", version_label)
  }, error = function(e) {
    stop("Snapshot creation failed: ", e$message)
  })
}

### 6. Markdown Management ###

# Convert DOCX to Markdown using Pandoc
convert_docx_to_markdown <- function(docx_path, markdown_path = NULL) {
  markdown_path <- ifelse(is.null(markdown_path), sub(".docx$", ".md", docx_path), markdown_path)
  if (!file.exists(docx_path)) stop("DOCX file does not exist: ", docx_path)

  tryCatch({
    system(paste("pandoc -f docx -t markdown_strict --wrap=none", shQuote(docx_path), "-o", shQuote(markdown_path)))
    if (!file.exists(markdown_path)) stop("Markdown conversion failed for: ", docx_path)
    return(markdown_path)
  }, error = function(e) {
    stop("Failed to convert DOCX to Markdown: ", e$message)
  })
}

# Clean Markdown content by removing unwanted tags
clean_formatting <- function(markdown_content) {
  clean_content <- str_replace_all(markdown_content, "<em1[^>]*>", "")
  str_replace_all(clean_content, "<em>|</em>", "")
}

# Convert and update Synapse Wiki from DOCX file
convert_and_update_wiki <- function(docx_path, synapse_id, wiki_id) {
  markdown_path <- convert_docx_to_markdown(docx_path)
  markdown_content <- read_file(markdown_path)
  cleaned_content <- clean_formatting(markdown_content)
  update_wiki_page(synapse_id, wiki_id, cleaned_content)
}

### 7. Folder Management ###

# Rename data directories by prepending institution prefix
rename_data_directories <- function(data_ids, institution_prefix) {
  for (data_id in data_ids) {
    # Get the folder entity by its Synapse ID
    folder <- synGet(data_id)

    # Check if the entity is a Folder
    if (folder$concreteType == "org.sagebionetworks.repo.model.Folder") {
      new_name <- paste0(institution_prefix, folder$name)

      # Rename the folder only if it hasn't already been renamed
      if (substring(folder$name, 1, nchar(institution_prefix)) != institution_prefix) {
        message("Renaming folder: ", folder$name, " to ", new_name)
        folder$name <- new_name
        synStore(folder)
      } else {
        message("Folder already renamed: ", folder$name)
      }
    } else {
      message("Entity is not a folder: ", data_id)
    }
  }
}


check_for_duplicates <- function(data) {
  # Function to check for duplicates in a dataset
}

add_study_to_staging_portal <- function(study_id) {
  # Function to add a study to the staging portal
}

verify_study_displayed_correctly <- function(study_id) {
  # Function to verify that a study is displayed correctly in the portal
}
