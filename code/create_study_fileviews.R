# Load required libraries and utility functions
library(synapser)
library(glue)
library(yaml)
library(purrr)
source("~/modelad/code/curation_utils.R")

synLogin()
config_path <- "~/modelad/projects/projects.yml"
projects_config <- read_yaml(config_path)
projects_fileview <- "syn51036997"

create_file_views <- function(projects_config) {
  walk(projects_config$projects, function(project) {
    project_name <- project$name
    parent_id <- projects_fileview

    walk(project$studies, function(study) {
      study_name <- study$name
      synapse_id <- study$synapseID

      file_view_name <- paste(project_name, study_name, sep = "_")
      cat("Creating file view for:", file_view_name, "\n")

      file_view_id <- create_file_view_schema(
        study_name = file_view_name,
        parent_id = parent_id,
        scopes = synapse_id
      )

      cat("Created file view for", file_view_name, "with ID:", file_view_id, "\n\n")
    })
  })
}

create_file_views(projects_config)
