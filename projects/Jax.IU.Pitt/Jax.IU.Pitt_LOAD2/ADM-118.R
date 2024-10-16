# ADM-118.R: Synapse Data Curation Script

# Load utility functions
source("modelad/code/curation_utils.R")

# Step 1: Authenticate with Synapse
login_to_synapse()

# Step 2: Define paths and load configuration
config_path <- file.path("modelad", "projects", "Jax.IU.Pitt_LOAD2")
config <- read_config(file.path(config_path, "study_config.yml"))

# Extract key values from the configuration
project_name <- config$study$name
parent_id <- config$study$ids$syn
staging_id <- config$study$ids$staging # Correct usage of staging folder ID
scopes <- extract_synapse_ids(config$study$data)
output_path <- file.path(config_path, "data")

# Step 3: Retrieve all folders in the project (specified by parent_id) and move them to the staging folder
folders_list <- as.list(synGetChildren(parent_id, includeTypes = list("folder"))$asList())
lapply(folders_list, function(folder) {
  folder_entity <- synGet(folder$id, downloadFile = FALSE)
  folder_entity$properties$parentId <- staging_id
  synStore(folder_entity)
  cat(folder_entity$properties$name, "moved to staging folder", staging_id, "\n")
})

# Step 4: Create a File View Schema
schema_id <- create_file_view_schema(
  name = project_name,
  parent = "syn2580853",
  scopes = scopes,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = FALSE,
  addAnnotationColumns = TRUE,
  columns = NULL
)

# Step 5: Download and View File View Content
fileview <- query_file_view_to_tibble(schema_id)
glimpse(fileview)

# Step 6: Download Metadata Files and Merge with Fileview
ind_meta <- read_and_preprocess(config$study$metadata$individual, download_path = output_path)
bio_meta <- read_and_preprocess(config$study$metadata$biospecimen, download_path = output_path)

# Read the latest template for individual metadata
ind_meta_template <- read.csv("path/to/ind_meta_template.csv")

# Ensure ind_meta matches the template format and merge it accordingly
ind_merged <- merge(ind_meta, ind_meta_template, all.x = TRUE)
missing_columns <- setdiff(names(ind_meta_template), names(ind_merged))
if (length(missing_columns) > 0) {
  cat("Missing columns in ind_meta:", paste(missing_columns, collapse = ", "), "\n")
}

# Print comparison of matching and missing columns
matching_columns <- intersect(names(ind_meta_template), names(ind_merged))
cat("Matching columns:", paste(matching_columns, collapse = ", "), "\n")

# Save the merged metadata to a file
write.csv(ind_merged, "path/to/ind_merged.csv", row.names = FALSE)

# Log the process
log_file_path <- file.path(config_path, "log.txt")
file.create(log_file_path)
cat("Script completed successfully.\n", file = log_file_path, append = TRUE)

n
