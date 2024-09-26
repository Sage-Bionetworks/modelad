# synapse_utils.R: Functions for managing Synapse entities and data synchronization

library(synapser)

# Function: Authenticate with Synapse
# Logs into Synapse using stored credentials.
synapse_auth <- function() {
    synLogin(silent = TRUE)
}

# Function: Filter Synapse entities based on specific annotations
# Filters child entities of a parent Synapse ID by given annotation key-value pairs.
filter_entities_by_annotation <- function(parent_id, annotation_key, annotation_value) {
    children <- synGetChildren(parent_id, includeTypes = list("folder", "file"))
    filtered_children <- list()

    for (child in children$asList()) {
        annotations <- synGetAnnotations(child$id)
        if (!is.null(annotations[[annotation_key]]) && annotations[[annotation_key]] == annotation_value) {
            filtered_children[[child$name]] <- child
        }
    }

    filtered_children <- Filter(Negate(is.null), filtered_children)
    return(filtered_children)
}

# Function: List files with a specific annotation key-value pair in Synapse
# Executes a query on Synapse entities based on parent ID and returns matching files.
list_files_with_annotation <- function(parent_id, annotation_key, annotation_value) {
    query <- paste0(
        "SELECT id, name FROM entity WHERE parentId == '", parent_id,
        "' AND entityType == 'org.sagebionetworks.repo.model.FileEntity'"
    )
    results <- tryCatch(
        {
            synQuery(query)
        },
        error = function(e) {
            message("Error querying Synapse: ", e$message)
            return(NULL)
        }
    )

    if (is.null(results) || nrow(results) == 0) {
        message("No files found matching the criteria.")
        return(NULL)
    }

    filtered_files <- list()
    for (i in seq_len(nrow(results))) {
        file_id <- results$`entity.id`[i]
        file_name <- results$`entity.name`[i]
        annotations <- synGetAnnotations(file_id)
        if (!is.null(annotations[[annotation_key]]) && annotations[[annotation_key]] == annotation_value) {
            filtered_files[[file_name]] <- annotations
        }
    }
    return(filtered_files)
}

# Function: Create a snapshot of a Synapse file view
# Creates a snapshot of the specified file view with a comment.
create_synapse_snapshot <- function(file_view_id, comment) {
    snapshot_id <- synCreateSnapshot(file_view_id, snapshotComment = comment)
    message("Snapshot created with ID: ", snapshot_id)
}

# Function: Sync files from Synapse folders
# Synchronizes files from a specified Synapse folder to a local directory.
download_synapse_files <- function(folder_id, study_name, base_path = "modelad/data") {
    download_path <- file.path(base_path, study_name)
    if (!dir.exists(download_path)) {
        dir.create(download_path, recursive = TRUE)
    }

    existing_files <- list.files(download_path, recursive = TRUE)
    tryCatch(
        {
            synapserutils::syncFromSynapse(folder_id, path = download_path, ifcollision = "keep.local")
            new_files <- setdiff(list.files(download_path, recursive = TRUE), existing_files)
            if (length(new_files) == 0) {
                message("No new files were downloaded from folder ID: ", folder_id)
            } else {
                message("Files downloaded successfully from folder ID: ", folder_id, " to ", download_path)
                message("New files: ", paste(new_files, collapse = ", "))
            }
        },
        error = function(e) {
            stop("Failed to download files from Synapse: ", e$message)
        }
    )
}

# Example usage
# synapse_auth()
# create_synapse_snapshot("syn12345678", "Created a new snapshot for review")
