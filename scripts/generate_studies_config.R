library(yaml)

# Define the base path for study directories
base_path <- "modelad/studies/"

# List all study directories
study_dirs <- list.dirs(base_path, recursive = FALSE)

# Function to create study config entry
create_study_entry <- function(study_dir) {
  study_name <- basename(study_dir)
  config_path <- file.path(study_dir, "study_config.yml")

  if (!file.exists(config_path)) {
    warning("Configuration file not found for study: ", study_name)
    return(NULL)
  }

  config <- tryCatch(read_yaml(config_path), error = function(e) {
    warning("Error reading configuration file for study: ", study_name, " - ", e$message)
    return(NULL)
  })

  if (is.null(config)) return(NULL)

  synID <- config$synIDs$study
  if (is.null(synID) || synID == "") {
    warning("synID is missing in the configuration file for study: ", study_name)
    return(NULL)
  }

  list(
    name = study_name,
    synID = synID,
    config_path = config_path,
    synapseURL = paste0("https://www.synapse.org/#!Synapse:", synID),
    stagingURL = paste0("https://staging.adknowledgeportal.synapse.org/Explore/Studies/DetailsPage/StudyDetails?Study=", synID)
  )
}

# Create the list of study entries
studies <- lapply(study_dirs, create_study_entry)
studies <- Filter(Negate(is.null), studies) # Remove NULL entries

# Create the full configuration
studies_config <- list(studies = studies)

# Write to YAML file
write_yaml(studies_config, file.path(base_path, "studies_config.yml"))

message("studies_config.yml has been generated.")
