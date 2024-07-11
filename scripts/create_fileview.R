# Clear the environment and load required libraries
rm(list = ls())
library(synapser)
library(yaml)
library(stringr)

synLogin(silent = TRUE)

config <- yaml::read_yaml("modelad/studies/studies_config.yml")
studies <- config$studies
parent_id <- "syn2580853"

create_fileview <- function(name, parent_id, scopes, include_default_columns = TRUE, include_annotation_columns = FALSE, ignored_columns = list()) {
  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = include_default_columns,
      addAnnotationColumns = include_annotation_columns,
      ignoredAnnotationColumnNames = ignored_columns
    )
    synStore(view)$properties$id
  }, error = function(e) {
    message("Error creating fileview ", name, ": ", e$message)
    NULL
  })
}

add_columns_to_fileview <- function(fileview_id, columns) {
  tryCatch({
    lapply(columns, function(column) {
      synStore(Column(name = column, columnType = "STRING", maximumSize = 100, parent = fileview_id))
    })
  }, error = function(e) {
    message("Error adding columns to fileview ", fileview_id, ": ", e$message)
    NULL
  })
}

create_individual_fileviews <- function(studies, parent_id, ignored_columns = list(), additional_columns = list()) {
  lapply(studies, function(study) {
    if (is.null(study$name) || is.null(study$synID) || study$synID == "") {
      message("Skipping study due to missing or invalid parameters: ", study$name)
      return(NULL)
    }
    name <- paste("MODEL-AD", study$name, "Fileview", sep = "_")
    id <- create_fileview(name, parent_id, list(study$synID), ignored_columns = ignored_columns)
    if (!is.null(id)) {
      message("Created fileview for ", study$name, " with ID: ", id)
      if (length(additional_columns) > 0) {
        add_columns_to_fileview(id, additional_columns)
        message("Added specific columns to fileview ", id)
      }
    }
  })
}

create_combined_fileview <- function(studies, parent_id,  include_default_columns = TRUE, include_annotation_columns = FALSEignored_columns = list()) {
  combined_name <- "MODEL-AD-Fileview"
  combined_scopes <- Filter(Negate(is.null), lapply(studies, function(study) {
    if (!is.null(study$synID) && study$synID != "") {
      return(study$synID)
    }
    NULL
  }))

  message("Combined scopes: ", paste(combined_scopes, collapse = ", "))
  combined_id <- create_fileview(combined_name, parent_id, combined_scopes, include_default_columns = TRUE, include_annotation_columns = FALSE, ignored_columns = ignored_columns)

  if (!is.null(combined_id)) {
    message("Created combined fileview with ID: ", combined_id)
  } else {
    message("Failed to create combined fileview")
  }
}

# Define ignored columns and additional columns
ignored_columns <- c("individualID")
additional_columns <- c("consortium", "study", "fileFormat",  include_default_columns = TRUE, include_annotation_columns = FALSE, "resourceType")

# Create individual fileviews
create_individual_fileviews(studies, parent_id, ignored_columns, additional_columns)

# Create combined fileview with only default columns
create_combined_fileview(studies, parent_id, ignored_columns)
