source("synapse_manager.R")

# Load fileview ID
load("fileview_id.RData")

# Initialize SynapseManager
synManager <- SynapseManager$new()

# Query the fileview to get existing annotations
df <- synManager$queryFileview(fileview_id)

# Save queried data
save(df, file = "queried_data.RData")
