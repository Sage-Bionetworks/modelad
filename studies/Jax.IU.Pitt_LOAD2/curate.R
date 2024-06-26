# main_script.R

# Load the functions script
source("modelad/scripts/functions.R")

# Main function to execute the script
main <- function() {
  # Log in to Synapse
  synLogin()


  # Define file IDs and target folder ID

  target_folder_id <- "syn51534997"


  data_ids <- c("syn51745755", "syn51745788", "syn51748055", "syn51904331", "syn53360242", "syn51748057", "syn51748058")

  for (data_id in data_ids) {
    # Move the file to the target folder
    move_file_to_folder(data_id, target_folder_id)
  }

  # Rename specific files as needed
  rename_file_if_needed("syn53360242", "Imaging")
  rename_file_if_needed("syn51748057", "Gene Expression (RNA-Seq raw)")
  rename_file_if_needed("syn51748058", "Gene Expression (RNA-Seq processed)")





} # main

# Execute the main function
main()
