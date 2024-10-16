# Load required libraries
library(synapser)
library(tidyverse)
library(yaml)
library(purrr)

# Authenticate with Synapse
invisible(synLogin())

# Load configuration
config_path <- "modelad/studies/Jax.IU.Pitt_Verubecestat_5XFAD/study_config.yml"
config <- yaml::read_yaml(config_path)

# Extract information
base_url <- "https://sagebionetworks.jira.com/browse/"
target_folder_id <- config$study$studyID
data_ids <- unlist(map(config$study$assays, "data"))
annotations_list <- list(contentType = "dataset", studyName = config$study$name, program = config$study$program)
file_view_id <- config$study$viewID

# Define functions
move_file <- function(file_id, folder_id) {
  synStore(synGet(file_id) %>% { .$parentId <- folder_id; . })
}

set_annotations <- function(file_id, annotations) {
  synSetAnnotations(file_id, annotations)
}

move_as_new_version <- function(synIDa, synIDb) {
  synStore(synGet(synIDb) %>% { .$filePath <- synGet(synIDa, downloadFile = TRUE)$path; . })
}

curate_annotations <- function(file_view_id, config) {
  annotations <- synTableQuery(paste("SELECT * FROM", file_view_id))$asDataFrame() %>% as_tibble() %>%
    filter(Program == "[\"MODEL-AD\"]", Study == config$study$name) %>%
    mutate(across(c(name, program, portal), ~ ifelse(is.na(.x) | .x != config$study[[cur_column()]], config$study[[cur_column()]], .x)))

  changes <- annotations %>% summarise(across(everything(), ~ sum(. != annotations[[cur_column()]])))
  print("Summary of changes:"); print(changes)

  synStore(synBuildTable("Updated Annotations", file_view_id, annotations))
}


query <- synTableQuery("SELECT * FROM syn61586472")
result <- read_csv(query$filepath) %>% as_tibble()
notes <- result %>% select(4,5, 25:38) %>% glimpse
notes %>% view

notes %>% fi
# Main tasks
# curate_annotations(file_view_id, config)
# move_as_new_version("syn52360062", "syn26136407")
# walk(data_ids, ~move_file(.x, target_folder_id))
# walk(data_ids, ~set_annotations(.x, annotations_list))

message("Dataset curation completed successfully.")
