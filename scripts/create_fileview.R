source("synapse_manager.R")

# Initialize SynapseManager
synManager <- SynapseManager$new()

# Create the fileview schema
fileview_id <- synManager$createFileviewSchema(
  name = "UCI_CCLines_Fileview",
  parentId = 'syn2580853',
  scopeId = 'syn51713891'
)

# Save fileview ID
save(fileview_id, file = "fileview_id.RData")
