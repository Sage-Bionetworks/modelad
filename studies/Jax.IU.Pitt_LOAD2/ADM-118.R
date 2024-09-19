# ADM-118.R: Synapse Data Curation Script for ADM-118 Project

# Load utility functions
source('modelad/scripts/curation_utils.R')

# Synapse login
login_to_synapse()

# Load study configuration
study_config <- yaml::read_yaml('modelad/studies/Jax.IU.Pitt_LOAD2/study_config.yml')

# Extract study details
metadata_ids <- study_config$study$metadata
data_ids <- study_config$study$data
study_id <- study_config$study$ids$syn
institution_prefix <- "Jax.IU.Pitt_"

# Ensure temporary directory exists
tmp_dir <- 'modelad/studies/Jax.IU.Pitt_LOAD2/tmp'
create_directory_if_not_exists(tmp_dir)

# Task control flags (default to FALSE)
move_folders <- FALSE
convert_docx_to_md <- FALSE
download_metadata <- FALSE
rename_directories <- FALSE

# Create file view scoped to Synapse study ID
create_file_view(study_config$study$name, study_config$study$backend_id, study_id)

# Move data folders (if enabled)
if (move_folders) move_folders_to_parent(data_ids, study_id)

# Download and preprocess metadata files (if enabled)
if (download_metadata) download_and_preprocess_metadata(metadata_ids, tmp_dir)

# Convert DOCX to Markdown (if enabled)
docx_path <- file.path(tmp_dir, "Jax.IU.Pitt_5XFAD_Deep_Phenotyping_FINAL.docx")
markdown_path <- sub(".docx$", ".md", docx_path)
if (convert_docx_to_md) convert_docx_to_markdown(docx_path, markdown_path)

# Rename data directories (if enabled)
if (rename_directories) rename_data_directories(data_ids, institution_prefix)
