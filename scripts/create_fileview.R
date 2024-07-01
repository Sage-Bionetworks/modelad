library(synapser)
library(yaml)
library(stringr)

synLogin(silent = TRUE)

config <- yaml::read_yaml("modelad/studies/studies_config.yml")
config_path_format <- config$config_path_format
studies <- config$studies

create_fileview <- function(name, parent_id, scopes, add_default = TRUE, add_annotation = TRUE) {
  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = list(scopes),
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = add_default,
      addAnnotationColumns = add_annotation
    )
    synStore(view)$properties$id
  }, error = function(e) {
    cat("Error creating fileview", name, ":", e$message, "\n")
    return(NULL)
  })
}

parent_id <- "syn2580853"

for (study in studies) {
  name <- paste("MODEL-AD", study$name, "Fileview", sep = "_")
  id <- create_fileview(name, parent_id, study$synID)
  if (!is.null(id)) {
    cat("Created fileview for", study$name, "with ID:", id, "\n")
    config_path <- str_replace_all(config_path_format, "\\{name\\}", study$name)
    cat("Config path for", study$name, ":", config_path, "\n")
  }
}

combined_name <- "MODEL-AD-Fileview"
combined_scopes <- lapply(studies, function(study) study$synID)
combined_id <- create_fileview(combined_name, parent_id, combined_scopes, add_default = TRUE, add_annotation = FALSE)
if (!is.null(combined_id)) {
  cat("Created combined fileview with ID:", combined_id, "\n")
}

