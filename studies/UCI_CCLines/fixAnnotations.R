# Load the SynapseManager class from the synapse_manager.R file
source("modelad/scripts/synapse_manager.R")

s# Initialize SynapseManager
synapse_manager <- SynapseManager$new()

# Define Synapse IDs for metadata files
# individual_metadata_synId <- 'syn53470893'
# biospecimen_metadata_synId <- 'syn53470890'
# assay_metadata_synId <- 'syn53470889'

# Prepare metadata
# final_metadata <- synapse_manager$prepare_metadata(individual_metadata_synId, biospecimen_metadata_synId, assay_metadata_synId)

# Create and upload the Synapse table
# fileview_id <- synapse_manager$create_and_upload_synapse_table("UCI_CCLines_Fileview", 'syn2580853', 'syn51713891', final_metadata)

# Query the fileview to verify
queried_metadata <- synapse_manager$download_metadata(fileview_id)

# Print final metadata for debugging
print("Queried metadata after upload:")
print(head(queried_metadata))
print(dim(queried_metadata))
