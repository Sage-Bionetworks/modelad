library(yaml)

# Install and load the synapser package
# Install synapser package if not already installed
if (!requireNamespace("synapser", quietly = TRUE)) {
  install.packages("synapser")
}
invisible(library(synapser))
invisible(synLogin(silent = TRUE))

# Define the Synapse ID of the parent directory (user should replace this with their own directory ID)
parentId <- "syn5550383"
base_dir <- 'modelad/studies'
file_pattern <- 'study_config.yml'

# Function to list files with a specific annotation key-value pair
list_files_with_annotation <- function(parentId, annotationKey, annotationValue) {
  # Query for all files under the specified parent directory
  query <- paste0("SELECT id, name FROM entity WHERE parentId == '", parentId,
                  "' AND entityType == 'org.sagebionetworks.repo.model.FileEntity'")
  print(query)

  results <- synQuery(query)

  # Initialize a list to hold files that match the annotation
  filtered_files <- list()

  # Loop through each file to check its annotations
  for (i in 1:nrow(results)) {
    file_id <- results$`entity.id`[i]
    file_name <- results$`entity.name`[i]

    # Get the annotations for the file
    annotations <- synGetAnnotations(file_id)

    # Check if the file has the specified annotation key and value
    if (!is.null(annotations[[annotationKey]]) && annotations[[annotationKey]] == annotationValue) {
      filtered_files[[file_name]] <- annotations
    }
  }

  return(filtered_files)
}

# Generalized function call:
# Users can specify the annotation key and value they want to filter by
# Example: To filter by program = "MODEL-AD"
program_name <- "MODEL-AD"
files_with_specific_program <- list_files_with_annotation(parentId, "program", program_name)

# Print the files and their annotations
print(files_with_specific_program)

# Logout from Synapse
synLogout()
