library(synapser)
library(yaml)

# Synapse login with feedback
tryCatch({
  invisible(synLogin(silent = TRUE))
}, error = function(e) {
  stop("Failed to log into Synapse: ", e$message)
})

# Specify the base directory and file pattern for YAML configuration files
base_dir <- 'modelad/studies'
file_pattern <- 'study_config.yml'

# Function to read and parse all YAML files in the given directory pattern
read_all_yaml_files <- function(base_dir, file_pattern) {

  # Search for files
  yaml_files <- list.files(path = base_dir, pattern = file_pattern, full.names = TRUE, recursive = TRUE)
  if (length(yaml_files) == 0) {
    stop("No YAML files found in the specified directory: ", base_dir)
  }

  message("Found YAML files:")
  message(paste(yaml_files, collapse = "\n"))

  # Read and combine the YAML files
  studies_list <- lapply(yaml_files, function(file) {
    tryCatch({
      yaml_content <- yaml::read_yaml(file)
      if (!is.null(yaml_content$study$name) && !is.null(yaml_content$study$ids$syn)) {
        return(list(studyID = yaml_content$study$name, synID = yaml_content$study$ids$syn))
      } else {
        message("YAML file missing required fields: ", file)
        return(NULL)
      }
    }, error = function(e) {
      message("Error reading YAML file ", file, ": ", e$message)
      return(NULL)
    })
  })

  # Filter out NULL entries
  studies_list <- Filter(Negate(is.null), studies_list)
  if (length(studies_list) == 0) {
    stop("No valid studies found in the YAML files.")
  }

  return(studies_list)
}

# Function to create a file view
create_fileview <- function(name, parent_id, scopes, ignored_columns = list()) {
  if (length(scopes) == 0) {
    message("No valid scopes provided for creating file view: ", name)
    return(NULL)
  }

  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = list(EntityViewType$FILE, EntityViewType$FOLDER),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = FALSE,
      ignoredAnnotationColumnNames = ignored_columns
    )
    synStore(view)$properties$id
  }, error = function(e) {
    message("Error creating fileview ", name, ": ", e$message)
    NULL
  })
}

# Function to add columns to a file view in a batch
add_columns_to_fileview <- function(fileview_id, columns) {
  if (length(columns) == 0) return(NULL)

  column_objects <- lapply(columns, function(column) {
    Column(name = column, columnType = "STRING", maximumSize = 200, parent = fileview_id)
  })

  tryCatch({
    synStore(column_objects)
  }, error = function(e) {
    message("Error adding columns: ", e$message)
  })
}

# Function to create individual file views for each study
create_individual_fileviews <- function(studies, parent_id, ignored_columns = list(), additional_columns = list()) {
  lapply(studies, function(study) {
    if (!is.null(study$studyID) && !is.null(study$synID)) {
      id <- create_fileview(paste("MODEL-AD", study$studyID, "Fileview", sep = "_"), parent_id, list(study$synID), ignored_columns)
      if (!is.null(id) && length(additional_columns) > 0) {
        add_columns_to_fileview(id, additional_columns)
      }
    }
  })
}

# Function to create a combined file view for all studies
create_combined_fileview <- function(studies, parent_id, ignored_columns = list()) {
  scopes <- lapply(studies, function(study) study$synID)
  scopes <- Filter(Negate(is.null), scopes)

  if (length(scopes) == 0) {
    message("No valid Synapse IDs to create a combined file view.")
    return(NULL)
  }

  create_fileview("MODEL-AD-Fileview", parent_id, scopes, ignored_columns)
}

# Main Script Execution

# Read and parse all YAML files
studies <- read_all_yaml_files(base_dir, file_pattern)

 # Set parent ID for file views
parent_id <- "syn2580853"

# Define ignored and additional columns
ignored_columns <- c("individualID")
additional_columns <- c("consortium", "study", "fileFormat", "resourceType")

# Create individual file views for each study
create_individual_fileviews(studies, parent_id, ignored_columns, additional_columns)

# Create a combined file view for all studies
create_combined_fileview(studies, parent_id, ignored_columns)

message("Script completed successfully.")
