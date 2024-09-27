# curation_utils.R: Utility Functions for Synapse Data Curation

# Load required libraries
library(synapser)
library(dplyr)
library(readr)
library(readxl)
library(glue)
library(yaml)
library(purrr)
library(stringr)

# Authenticate with Synapse
login_to_synapse <- function() {
  synLogin()
  cat("Logged into Synapse.\n")
}

# Read configuration from a YAML file
read_config <- function(config_path) {
  yaml::read_yaml(config_path)
}

# Extract Synapse IDs from the study data section
extract_synapse_ids <- function(data_section) {
  unlist(lapply(data_section, function(x) if (is.character(x)) x else unlist(x)))
}

# Create and store a Synapse file view schema
create_file_view_schema <- function(study_name, parent_id, scopes, columns = NULL) {
  schema <- EntityViewSchema(
    name = study_name,
    parent = parent_id,
    scopes = scopes,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE,
    columns = columns
  )
  synStore(schema)$properties$id
}

# Query file view content and return as a tibble
query_file_view_to_tibble <- function(fileview_id) {
  synTableQuery(paste("SELECT * FROM", fileview_id))$asDataFrame() %>% as_tibble()
}

# Set annotations on a Synapse entity
set_annotations <- function(entity_id, annotations_list) {
  entity <- synGet(entity_id)
  entity$annotations <- annotations_list
  synStore(entity)
}

# Download data from Synapse
download_data <- function(synID, download_path) {
  if (!dir.exists(download_path)) dir.create(download_path, recursive = TRUE)
  synGet(synID, downloadLocation = download_path)
}

# Move files to a specified folder
move_file_to_folder <- function(file_id, target_folder_id) {
  file <- synGet(file_id)
  file$parentId <- target_folder_id
  synStore(file, forceVersion = FALSE)
}

# Rename files if needed
rename_file_if_needed <- function(file_id, new_name) {
  file <- synGet(file_id)
  if (file$name != new_name) {
    file$name <- new_name
    synStore(file, forceVersion = FALSE)
  }
}

# Get all file names in a folder
get_file_names_in_folder <- function(folder_id) {
  map_chr(synGetChildren(folder_id)$asList(), "name")
}

# Update a Synapse wiki page
update_wiki_page <- function(synapse_id, wiki_id, new_content) {
  wiki <- synGetWiki(owner = synapse_id, wikiId = wiki_id)
  wiki$markdown <- new_content
  synStore(wiki)
}

# Clean formatting in markdown content
clean_formatting <- function(markdown_content) {
  str_replace_all(markdown_content, "<em1[^>]*>|<em>|</em>", "")
}

# Convert DOCX to Markdown and update Synapse wiki
convert_and_update_wiki <- function(file_name, file_mappings, dry_run = TRUE) {
  wiki_project <- file_mappings[[file_name]]
  doc_path <- file.path("modelad/data/docs", file_name)
  output_file <- sub(".docx$", ".md", doc_path)
  system(paste("pandoc -f docx -t markdown_strict --wrap=none -o", output_file, doc_path))
  clean_markdown <- clean_formatting(read_file(output_file))
  if (!dry_run) update_wiki_page(wiki_project$id, wiki_project$wikiId, clean_markdown)
}

# Process metadata files with templates
process_metadata_file <- function(file_id, template_path, download_path, output_path, file_name) {
  data <- download_and_read_data(file_id, download_path)
  template <- read_xlsx(template_path) %>% as_tibble()
  data_edit <- data %>%
    select(any_of(names(template))) %>%
    bind_cols(template %>% select(-any_of(names(data))))
  write_csv(data_edit, file.path(output_path, paste0(file_name, "_EDIT.csv")))
}

# Execute defined tasks based on configuration
execute_study_tasks <- function(config) {
  tasks <- list(
    list("Download Metadata", TRUE, function() {
      download_synapse_files(config$study$metadata, config$study$name)
    }),
    list("Move Folders", config$study$existing, function() {
      move_folders_to_parent(config$study$data, config$study$ids$syn)
    }),
    list("Convert DOCX to Markdown", FALSE, function() {
      convert_docx_to_markdown("Jax.IU.Pitt_5XFAD_Deep_Phenotyping_FINAL.docx")
    }),
    list("Rename Directories", FALSE, function() {
      rename_data_directories(config$study$data, config$study$name)
    })
  )
  lapply(tasks, function(task) execute_task(task[[1]], task[[2]], task[[3]]))
}

# Execute task if the flag is set to TRUE
execute_task <- function(task_name, flag, action) {
  if (flag) action() else cat("Skipped:", task_name, "\n")
}

# Function to perform left join and handle duplicate columns
left_join_no_dup <- function(x, y, by) {
  common_columns <- setdiff(intersect(names(x), names(y)), by)
  if (length(common_columns) > 0) {
    x <- x %>% rename_with(~ paste0(., ".x"), all_of(common_columns))
    y <- y %>% rename_with(~ paste0(., ".y"), all_of(common_columns))
    result <- left_join(x, y, by = by)
    for (col in common_columns) {
      result[[col]] <- coalesce(result[[paste0(col, ".x")]], result[[paste0(col, ".y")]])
      result <- result %>% select(-all_of(paste0(col, c(".x", ".y"))))
    }
  } else {
    result <- left_join(x, y, by = by)
  }
  result
}
