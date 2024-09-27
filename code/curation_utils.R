# curation_utils.R: Utility Functions for Synapse Data Curation

# Load required libraries
library(synapser)
library(dplyr)
library(readr)
library(readxl)
library(glue)
library(yaml)
library(purrr)  # For handling nested lists

# Authenticate with Synapse
login_to_synapse <- function() {
  synLogin()
  cat("Logged into Synapse.\n")
}

# Read configuration from a YAML file
read_config <- function(config_path) {
  yaml::read_yaml(config_path)
}

# Dynamically extract all Synapse IDs from the study data section of the configuration
extract_synapse_ids <- function(data_section) {
  # Recursively flatten lists and extract Synapse IDs
  ids <- unlist(lapply(data_section, function(x) {
    if (is.character(x)) {
      return(x)  # Direct Synapse ID
    } else if (is.list(x)) {
      return(unlist(x))  # Flatten nested lists to extract all IDs
    }
  }))
  return(ids)
}

# Create a Synapse file view schema, store it, and return the view ID
create_file_view_schema <- function(study_name, parent_id, scopes, columns = NULL) {
  tryCatch({
    # Configure file view schema
    schema <- EntityViewSchema(
      name = study_name,
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = c(EntityViewType$FILE),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = TRUE,
      columns = columns
    )
    
    # Store the schema in Synapse
    stored_schema <- synStore(schema)
    cat("File view schema created and uploaded successfully with ID:", stored_schema$properties$id, "\n")
    return(stored_schema$properties$id)
  }, error = function(e) {
    stop("Error creating or storing file view schema:", e$message)
  })
}

# Query the file view content from Synapse and return as a tibble
query_file_view_to_tibble <- function(fileview_id) {
  tryCatch({
    query <- paste("SELECT * FROM", fileview_id)
    data <- synTableQuery(query)$asDataFrame() %>% as_tibble()
    cat("File view queried successfully. Number of rows:", nrow(data), "\n")
    return(data)
  }, error = function(e) {
    stop("Error querying file view:", e$message)
  })
}

# Add or modify annotations for Synapse files
set_annotations <- function(entity_id, annotations) {
  tryCatch({
    entity <- synGet(entity_id)
    existing_annots <- synGetAnnotations(entity)
    updated_annots <- c(existing_annots, annotations) # Merge existing and new annotations
    synSetAnnotations(entity, annotations = updated_annots)
    cat("Annotations set successfully for entity:", entity_id, "\n")
  }, error = function(e) {
    stop("Error setting annotations:", e$message)
  })
}

# Update or store a modified file view using synStore
update_file_view <- function(fileview_data, output_path) {
  tryCatch({
    # Save the modified fileview data locally
    modified_file <- file.path(output_path, "fileview_new.csv")
    write_csv(fileview_data, modified_file)
    
    # Create a Synapse File object and store it
    file <- File(path = modified_file, parentId = "synParentID")  # Update parentId as needed
    stored_file 
