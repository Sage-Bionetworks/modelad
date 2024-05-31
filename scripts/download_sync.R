# download_sync.R

download_synapse_files <- function(folder_id, study_name, base_path = "modelad/data") {
  download_path <- file.path(base_path, study_name)
  if (!dir.exists(download_path)) {
    dir.create(download_path, recursive = TRUE)
  }

  existing_files <- list.files(download_path, recursive = TRUE)
  tryCatch({
    synapserutils::syncFromSynapse(folder_id, path = download_path, ifcollision = "keep.local")
    new_files <- setdiff(list.files(download_path, recursive = TRUE), existing_files)
    if (length(new_files) == 0) {
      message("No new files were downloaded from folder ID: ", folder_id)
    } else {
      message("Files downloaded successfully from folder ID: ", folder_id, " to ", download_path)
      message("New files: ", paste(new_files, collapse = ", "))
    }
  }, error = function(e) {
    stop("Failed to download files from Synapse: ", e$message)
  })
}
