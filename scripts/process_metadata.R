library(dplyr)
library(janitor)

# Load preprocessed data
load("individual_metadata.RData")
load("biospecimen_metadata.RData")
load("assay_metadata.RData")
load("queried_data.RData")

# Ensure `individualID` and `specimenID` are character type
individual_metadata <- individual_metadata %>% mutate(individualID = as.character(individualID))
biospecimen_metadata <- biospecimen_metadata %>% mutate(individualID = as.character(individualID), specimenID = as.character(specimenID))
assay_metadata <- assay_metadata %>% mutate(specimenID = as.character(specimenID))

# Perform left joins
combined_metadata <- individual_metadata %>%
  left_join(biospecimen_metadata, by = "individualID") %>%
  left_join(assay_metadata, by = c("assay", "specimenID"))

# Remove all empty columns and rows from combined_metadata
clean_metadata <- combined_metadata %>%
  select(where(~ !all(is.na(.)))) %>%
  filter(rowSums(is.na(.)) != ncol(.))

# Load SynapseManager and fileview_id
source("synapse_manager.R")
load("fileview_id.RData")

# Initialize SynapseManager
synManager <- SynapseManager$new()

# Perform coalesce join and remove empty columns
final_metadata_coalesce <- synManager$coalesce_join(clean_metadata, df, by = c("individualID", "specimenID"))
final_metadata_coalesce <- final_metadata_coalesce %>% remove_empty("cols") %>% distinct()

# Save final coalesced metadata
save(final_metadata_coalesce, file = "final_metadata_coalesce.RData")
