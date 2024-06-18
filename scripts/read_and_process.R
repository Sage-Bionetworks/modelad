source("synapse_manager.R")

# Define Synapse IDs for metadata files
individual_metadata_synId <- 'syn53470893'
biospecimen_metadata_synId <- 'syn53470890'
assay_metadata_synId <- 'syn53470889'

# Initialize SynapseManager
synManager <- SynapseManager$new()

# Download and preprocess metadata files
individual_metadata <- synManager$read_and_preprocess(individual_metadata_synId)
biospecimen_metadata <- synManager$read_and_preprocess(biospecimen_metadata_synId)
assay_metadata <- synManager$read_and_preprocess(assay_metadata_synId)

# Save preprocessed data
save(individual_metadata, file = "individual_metadata.RData")
save(biospecimen_metadata, file = "biospecimen_metadata.RData")
save(assay_metadata, file = "assay_metadata.RData")
