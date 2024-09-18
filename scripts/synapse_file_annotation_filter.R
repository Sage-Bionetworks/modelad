library(yaml)

# Install and load the synapser package
# Install synapser package if not already installed
if (!requireNamespace("synapser", quietly = TRUE)) {
  install.packages("synapser")
}
invisible(library(synapser))
invisible(synLogin(silent = TRUE))
# synapser API documentation
# https://help.synapse.org/docs/API-Clients-and-Documentation.1985446128.html
 # browseVignettes(package = "synapser")


base_dir <- 'modelad/studies'
file_pattern <- 'study_config.yml'
# Define the Synapse ID of the parent directory (user should replace this with their own directory ID)

parentId <- "syn5550383"
children <- synGetChildren(parentId, includeTypes = list("folder", "file"))

filtered_children <- list()
for (child in children$asList()) {
  annotations <- synGetAnnotations(child$id)
  if (!is.null(annotations[["program"]]) && annotations[["program"]] == "MODEL-AD") {
    filtered_children[[child$name]] <- child
  }
}

# Display filtered results
print(filtered_children)



# Remove NULL entries (children that don't match the annotation)
filtered_children <- Filter(Negate(is.null), filtered_children)



# Function to list files with a specific annotation key-value pair
list_files_with_annotation <- function(parentId, annotationKey, annotationValue) {
  # Query for all files under the specified parent directory
  query <- paste0("SELECT id, name FROM entity WHERE parentId == '", parentId,"'")
  print(query)

  # Using synFindEntities to find files under the parentId
  results <- synGetChildren(parentId = parentId)

  # Initialize a list to hold files that match the annotation
  filtered_files <- list()

  # Loop through each file to check its annotations
  for (i in seq_along(results)) {
    file_id <- results[[i]]$id
    file_name <- results[[i]]$name

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
