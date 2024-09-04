# curation_utils.R: Synapse Curation Utility Functions
# Provides reusable functions for common Synapse data curation tasks.

# Load necessary libraries
library(synapser)
library(dplyr)
library(readr)
library(janitor)
library(stringr)
library(yaml)
library(purrr)

### Synapse Authentication ###

# Function to log in to Synapse
login_to_synapse <- function(silent = TRUE) {
  tryCatch({
    synLogin(silent = silent)
    message("Logged in to Synapse.")
  }, error = function(e) {
    stop("Failed to log in to Synapse: ", e$message)
  })
}

### YAML Configuration Management ###

# Function to read a YAML configuration file and extract study names and Synapse IDs
read_studies_config <- function(file) {
  tryCatch({
    yaml_content <- yaml::read_yaml(file)

    # Extract study names and Synapse IDs
    studies <- lapply(yaml_content$studies, function(study) {
      if (!is.null(study$name) && !is.null(study$synID)) {
        return(list(studyID = study$name, synID = study$synID))
      }
      return(NULL)
    })

    # Remove NULL entries
    studies <- Filter(Negate(is.null), studies)
    return(studies)
  }, error = function(e) {
    message("Error reading YAML file '", file, "': ", e$message)
    return(NULL)
  })
}

### Synapse Entity Management ###

# Function to add a local file to a Synapse project or folder
add_file_to_synapse <- function(file_path, parent_id) {
  tryCatch({
    file <- File(path = file_path, parentId = parent_id)
    synStore(file)
    message("File ", basename(file_path), " added to Synapse under ", parent_id)
  }, error = function(e) {
    message("Failed to add file ", basename(file_path), " to Synapse: ", e$message)
  })
}

# Function to move a Synapse file or folder to a new parent location, only if needed
move_entity_to_new_parent <- function(entity_id, new_parent_id) {
  tryCatch({
    entity <- synGet(entity_id, downloadFile = FALSE)
    if (entity$properties$parentId != new_parent_id) {
      entity$properties$parentId <- new_parent_id
      synStore(entity)
      message("Entity ", entity_id, " moved to new parent location ", new_parent_id)
    } else {
      message("Entity ", entity_id, " is already in the target location ", new_parent_id)
    }
  }, error = function(e) {
    message("Failed to move entity ", entity_id, " to new parent location ", new_parent_id, ": ", e$message)
  })
}

# Function to set annotations on a Synapse entity
set_annotations <- function(entity_id, annotations_list) {
  tryCatch({
    entity <- synGet(entity_id, downloadFile = FALSE)
    entity$annotations <- annotations_list
    synStore(entity)
    message("Set annotations for entity ID: ", entity_id)
  }, error = function(e) {
    message("Failed to set annotations for entity ID: ", entity_id, ": ", e$message)
  })
}

### Data Download and Processing ###

# Function to download and preprocess files from Synapse
download_and_preprocess <- function(syn_id, download_path = tempdir()) {
  tryCatch({
    file_path <- synGet(syn_id, downloadLocation = download_path, ifcollision = "overwrite.local")$path
    data <- read_csv(file_path) %>%
      clean_names() %>%
      remove_empty(c("rows", "cols"))
    return(data)
  }, error = function(e) {
    message("Error downloading or processing file: ", syn_id, " - ", e$message)
    return(NULL)
  })
}

### File View and Wiki Management ###

# Function to create Synapse file views
create_file_view <- function(name, parent_id, scope_id) {
  tryCatch({
    view <- EntityViewSchema(
      name = name,
      parent = parent_id,
      scopes = list(scope_id),
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = FALSE
    )
    view_id <- synStore(view)$properties$id
    message("Created file view: ", name, " with ID: ", view_id)
    return(view_id)
  }, error = function(e) {
    message("Error creating file view: ", name, " - ", e$message)
    return(NULL)
  })
}

# Function to create a file view for all studies
create_study_overview_fileview <- function(studies, parent_id) {
  if (length(studies) == 0) {
    message("No studies provided to create the overview file view.")
    return(NULL)
  }

  tryCatch({
    scopes <- vapply(studies, function(study) study$synID, character(1))
    view <- EntityViewSchema(
      name = "MODEL-AD Study Overview",
      parent = parent_id,
      scopes = scopes,
      includeEntityTypes = list(EntityViewType$FILE),
      addDefaultViewColumns = TRUE,
      addAnnotationColumns = FALSE
    )
    view_id <- synStore(view)$properties$id
    message("Successfully created overview file view with ID: ", view_id)
    return(view_id)
  }, error = function(e) {
    message("Error creating study overview fileview: ", e$message)
    return(NULL)
  })
}

# Function to create individual file views for each study
create_individual_study_fileviews <- function(studies, parent_id) {
  lapply(studies, function(study) {
    if (!is.null(study$studyID) && !is.null(study$synID)) {
      tryCatch({
        view <- EntityViewSchema(
          name = paste0("MODEL-AD_", study$studyID, "_Fileview"),
          parent = parent_id,
          scopes = list(study$synID),
          includeEntityTypes = list(EntityViewType$FILE),
          addDefaultViewColumns = TRUE,
          addAnnotationColumns = FALSE
        )
        view_id <- synStore(view)$properties$id
        message("Successfully created file view for study ", study$studyID, " with ID: ", view_id)
      }, error = function(e) {
        message("Error creating fileview for study ", study$studyID, ": ", e$message)
      })
    } else {
      message("Study ID or Synapse ID is missing for a study. Skipping...")
    }
  })
}

# Function to update Synapse wiki page
update_wiki_page <- function(synapse_id, wiki_id, new_content) {
  tryCatch({
    wiki <- synGetWiki(owner = synapse_id, wikiId = wiki_id)
    wiki$markdown <- new_content
    synStore(wiki)
    message("Wiki page updated successfully: ", wiki_id)
  }, error = function(e) {
    message("Failed to update wiki page ", wiki_id, ": ", e$message)
  })
}

### Utility Functions ###

# Function to clean formatting in markdown content
clean_formatting <- function(markdown_content) {
  clean_content <- str_replace_all(markdown_content, "<em1[^>]*>", "")
  clean_content <- str_replace_all(clean_content, "<em>|</em>", "")
  return(clean_content)
}

# Function to coalesce joins (useful for merging data frames with overlapping column names)
coalesce_join <- function(x, y, by = NULL, suffix = c(".x", ".y"), join = dplyr::full_join, ...) {
  joined <- join(x, y, by = by, suffix = suffix, ...)
  cols <- union(names(x), names(y))
  to_coalesce <- names(joined)[!names(joined) %in% cols]
  suffix_used <- suffix[ifelse(endsWith(to_coalesce, suffix[1]), 1, 2)]
  to_coalesce <- unique(substr(to_coalesce, 1, nchar(to_coalesce) - nchar(suffix_used)))
  coalesced <- purrr::map_dfc(to_coalesce, ~dplyr::coalesce(joined[[paste0(.x, suffix[1])]], joined[[paste0(.x, suffix[2])]]))
  names(coalesced) <- to_coalesce
  bind_cols(joined, coalesced)[cols]
}

# Function to create a directory if it does not exist
create_directory_if_not_exists <- function(dir_path) {
  if (!dir.exists(dir_path)) dir.create(dir_path, recursive = TRUE)
}

# Function to add a study to Synapse studies table (Placeholder)
add_study_to_synapse_table <- function(study_config) {
  tryCatch({
    # Placeholder implementation; needs actual logic
    message("Study added to Synapse studies table: ", study_config$study$ids$syn)
  }, error = function(e) {
    message("Failed to add study to Synapse studies table: ", e$message)
  })
}

# Function to convert DOCX to Markdown
convert_docx_to_markdown <- function(docx_path) {
  tryCatch({
    markdown_path <- sub(".docx$", ".md", docx_path)
    system(paste0("pandoc -f docx -t markdown_strict --wrap=none '", docx_path, "' -o '", markdown_path, "'")) %>% print()
    return(markdown_path)
  }, error = function(e) {
    message("Failed to convert DOCX to Markdown: ", e$message)
    return(NULL)
  })
}

# Function to update study description on Synapse
update_study_description <- function(synapse_id, markdown_path) {
  tryCatch({
    content <- read_file(markdown_path)
    update_wiki_page(synapse_id, wiki_id = NULL, new_content = content)
    message("Study description updated on Synapse.")
  }, error = function(e) {
    message("Failed to update study description: ", e$message)
  })
}

# Function to add methods to data directories (Placeholder)
add_methods_to_data_directories <- function(data_ids) {
  tryCatch({
    # Placeholder implementation; needs actual logic
    message("Methods added to data directories.")
  }, error = function(e) {
    message("Failed to add methods to data directories: ", e$message)
  })
}
