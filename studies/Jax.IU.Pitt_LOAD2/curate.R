# Load the functions script
source("modelad/scripts/functions.R")

# Main function to execute the script
main <- function() {
  # Log in to Synapse
  synLogin()

  # Define file IDs and target folder ID
  target_folder_id <- "syn51535045"
  data_ids <- c("syn59479899", "syn59479678", "syn59479679")
  #
  # # Annotations to set
  # annotations_list <- list(contentType = "dataset")
  #
  # for (data_id in data_ids) {
  #   # Move the file to the target folder
  #   move_file_to_folder(data_id, target_folder_id)
  #   set_annotations(data_id, annotations_list)
  #
  # }
  #
  # # Rename specific files as needed
  # rename_file_if_needed("syn53360242", "Imaging")
  # rename_file_if_needed("syn51748057", "Gene Expression (RNA-Seq raw)")
  # rename_file_if_needed("syn51748058", "Gene Expression (RNA-Seq processed)")




}

# Execute the main function
main()
