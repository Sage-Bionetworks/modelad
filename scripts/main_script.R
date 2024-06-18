# main_script.R

# Source the required scripts
source("scripts/download_sync.R")
source("scripts/convert_files.R")
source("scripts/process_data.R")
source("scripts/update_wiki.R")

# Example usage of the functions
input_paths <- c(
  "modelad/data/templates/individual_animal_metadata_template.xlsx",
  "modelad/data/templates/biospecimen_metadata_template.xlsx",
  "modelad/data/templates/assay_rnaSeq_metadata_template.xlsx"
)

lapply(input_paths, convert_if_not_exists)

# Additional main script logic as needed
