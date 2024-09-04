# ADM-118.R: Script for Synapse Data Curation for ADM-118 Project

# Load utility functions
source('modelad/scripts/curation_utils.R')

# Synapse login
login_to_synapse()

# Load study configuration
study_config <- yaml::read_yaml('modelad/studies/Jax.IU.Pitt_LOAD2/study_config.yml')

# Extract study details from configuration
metadata_ids <- study_config$study$metadata
data_ids <- study_config$study$data
study_id <- study_config$study$ids$syn
backend_id <- "syn2580853"

# Ensure temporary directory exists
tmp_dir <- 'modelad/studies/Jax.IU.Pitt_LOAD2/tmp'
create_directory_if_not_exists(tmp_dir)

# Create a file view scoped to the Synapse study ID
create_file_view(study_config$study$name, backend_id, study_id)

# Move data folders to the new parent folder
lapply(data_ids, function(id) {
  move_entity_to_new_parent(id, new_parent_id = study_id)
})

# Download and preprocess metadata files
metadata_list <- lapply(metadata_ids, function(id) {
  download_and_preprocess(id, download_path = tmp_dir)
})

# Path to the DOCX file
docx_path <- 'modelad/studies/Jax.IU.Pitt_LOAD2/tmp/Jax.IU.Pitt_5XFAD_Deep_Phenotyping_FINAL.docx'

# Check if DOCX file exists
if (!file.exists(docx_path)) {
  stop("Error: DOCX file does not exist at the specified path: ", docx_path)
} else {
  message("DOCX file found: ", docx_path)
}

# Convert DOCX to Markdown using pandoc
markdown_path <- sub(".docx$", ".md", docx_path)
pandoc_command <- paste("pandoc -f docx -t markdown_strict --wrap=none", shQuote(docx_path), "-o", shQuote(markdown_path))

# Execute the pandoc command and check for errors
system_status <- system(pandoc_command, intern = TRUE, ignore.stderr = TRUE)

if (!file.exists(markdown_path)) {
  stop("Error: Markdown conversion failed. Check if pandoc is installed and accessible.")
} else {
  message("DOCX file successfully converted to Markdown: ", markdown_path)
}

