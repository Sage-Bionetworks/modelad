# "SELECT * FROM syn11346063.<latest snapshot version> WHERE ( \"study\" HAS ( '<study abbreviation>' ) )"

# Clear the environment and load required libraries
rm(list = ls())
library(synapser)
library(yaml)
library(tidyverse)

# Authenticate with Synapse
synLogin(silent = TRUE)

# Load configuration
config <- yaml::read_yaml("modelad/studies/studies_config.yml")
studies <- config$studies
parent_id <- "syn2580853"

# Function to download fileview as a tibble
download_fileview_as_tibble <- function(fileview_id) {
  tryCatch({
    query_result <- synTableQuery(paste("SELECT * FROM", fileview_id))
    df <- read_csv(query_result$filepath)
    as_tibble(df)
  }, error = function(e) {
    message("Error downloading fileview ", fileview_id, ": ", e$message)
    NULL
  })
}

# Function to create fileview name
create_fileview_name <- function(study_name) {
  paste("MODEL-AD", study_name, "Fileview", sep = "_")
}

# Download fileviews for each study
download_fileviews <- function(studies) {
  lapply(studies, function(study) {
    if (is.null(study$name) || is.null(study$synID) || study$synID == "") {
      message("Skipping study due to missing or invalid parameters: ", study$name)
      return(NULL)
    }
    fileview_name <- create_fileview_name(study$name)
    fileview_id <- synFindEntityId(fileview_name, parent_id)
    if (!is.null(fileview_id)) {
      message("Downloading fileview for ", study$name, " with ID: ", fileview_id)
      tibble <- download_fileview_as_tibble(fileview_id)
      if (!is.null(tibble)) {
        saveRDS(tibble, file = paste0("tibbles/", study$name, "_fileview.rds"))
        message("Fileview for ", study$name, " saved as tibble.")
      }
    } else {
      message("Fileview ID not found for ", fileview_name)
    }
  })
}

# Create directory for tibbles if it doesn't exist
if (!dir.exists("tibbles")) {
  dir.create("tibbles")
}

# Download fileviews as tibbles
download_fileviews(studies)
