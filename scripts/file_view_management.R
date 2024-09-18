library(synapser)

# Synapse login
synapse_login <- function() {
  synLogin(silent = TRUE)
}

# Function to create a file view with error handling
create_file_view <- function(name, parent_id, scopes) {
  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = list(EntityViewType$FILE, EntityViewType$FOLDER),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = TRUE
    )
    view <- synStore(view)
    message("File view created with ID: ", view$properties$id)
    return(view$properties$id)
  }, error = function(e) {
    if (grepl("Duplicate column name", e$message)) {
      message("Error: Duplicate column name in file view ", name)
    } else {
      message("Error creating file view ", name, ": ", e$message)
    }
    return(NULL)
  })
}

# Function to create a file view for each study
create_study_file_views <- function(studies, parent_id) {
  lapply(studies, function(study) {
    if (!is.null(study$name) && !is.null(study$synID) && study$synID != "") {
      view_name <- paste("MODEL-AD", study$name, "Fileview", sep = "_")
      create_file_view(view_name, parent_id, list(study$synID))
    } else {
      message("Skipping study due to missing name or synID: ", study)
    }
  })
}

# Main function to run the script
main <- function() {
  config_path <- "config/studies_config.yml"
  parent_id <- "syn2580853"
  
  # Load configuration
  config <- load_config(config_path)
  studies <- config$studies
  
  # Synapse login
  synapse_login()
  
  # Create file views for each study
  create_study_file_views(studies, parent_id)
}

# Run the main function if this script is executed
if (interactive()) {
  main()
}
