# Load necessary libraries
library(synapser)
library(yaml)

# Synapse login
synLogin(silent = TRUE)

# Path to the main YAML configuration file
config_file <- 'modelad/studies/studies_config.yml'

# Function to read the studies_config.yml and extract study names and synIDs
read_studies_config <- function(file) {
  tryCatch({
    yaml_content <- yaml::read_yaml(file)

    # Extract study names and synIDs
    studies <- lapply(yaml_content$studies, function(study) {
      if (!is.null(study$name) && !is.null(study$synID)) {
        return(list(studyID = study$name, synID = study$synID))
      }
      return(NULL)
    })

    # Remove NULL entries
    studies <- Filter(Negate(is.null), studies)
    return(studies)

  }, error = function(e) {
    message("Error reading YAML file '", file, "': ", e$message)
    return(NULL)
  })
}

# Read the configuration
studies_list <- read_studies_config(config_file)

# Function to create a file view for all studies
create_study_overview_fileview <- function(studies, parent_id) {
  if (length(studies) == 0) {
    message("No studies provided to create the overview file view.")
    return(NULL)
  }

  tryCatch({
    # Collect all Synapse IDs from the studies list
    scopes <- vapply(studies, function(study) study$synID, character(1))

    # Define the file view
    view <- EntityViewSchema(
      name = "MODEL-AD Study Overview",
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = FALSE
    )

    # Store the view on Synapse and return the ID
    view_id <- synStore(view)$properties$id
    message("Successfully created overview file view with ID: ", view_id)
    return(view_id)

  }, error = function(e) {
    message("Error creating study overview fileview: ", e$message)
    return(NULL)
  })
}

# Function to create a file view for each study
create_individual_study_fileviews <- function(studies, parent_id) {
  lapply(studies, function(study) {
    if (!is.null(study$studyID) && !is.null(study$synID)) {
      tryCatch({
        # Define the file view
        view <- EntityViewSchema(
          name = paste0("MODEL-AD_", study$studyID, "_Fileview"),
          parent = parent_id,
          scopes = list(study$synID),
          includeEntityTypes = list(EntityViewType$FILE),
          addDefaultViewColumns = TRUE,
          addAnnotationColumns = FALSE
        )

        # Store the view on Synapse
        view_id <- synStore(view)$properties$id
        message("Successfully created file view for study ", study$studyID, " with ID: ", view_id)

      }, error = function(e) {
        message("Error creating fileview for study ", study$studyID, ": ", e$message)
      })
    } else {
      message("Study ID or Synapse ID is missing for a study. Skipping...")
    }
  })
}

# Set the parent ID where the views will be created
parent_id <- "syn2580853"  # Replace with your actual Synapse parent ID

# Create the study overview file view if the study list is not empty
if (!is.null(studies_list)) {
  create_study_overview_fileview(studies_list, parent_id)

  # Create individual file views for each study
  create_individual_study_fileviews(studies_list, parent_id)
}

message("Script completed.")