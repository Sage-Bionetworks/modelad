# Load the synapser package
library(synapser)

# Authenticate with Synapse
synLogin()

# Define the Synapse ID of the File View
file_view_id <- "syn11346063"

# Retrieve the current version number of the file view
entity <- synGet(file_view_id)
current_version <- entity$properties$versionNumber
new_version <- current_version + 1

# Generate the snapshot comment based on the current year and month
snapshot_comment <- format(Sys.Date(), "%y.%m data release")

# Show what changes will be made
cat("Creating a snapshot for Synapse ID:", file_view_id, "\n")
cat("Current version:", current_version, "\n")
cat("New version:", new_version, "\n")
cat("Snapshot comment:", snapshot_comment, "\n")

# Create the snapshot using synCreateSnapshotVersion
snapshot <- synCreateSnapshotVersion(entity = file_view_id, snapshotComment = snapshot_comment)

# Print the snapshot details
print(snapshot)

# Assign a DOI to the snapshot
# Define DOI details
doi_details <- list(
  doi = FALSE,
  doiTitle = snapshot_comment,
  doiAuthors = "Sage Bionetworks",
  doiType = "Collection"
)

# Get the newly created snapshot version ID
snapshot_version <- snapshot$versionNumber

# Print confirmation
cat("Snapshot created with version", snapshot_version, "and comment:", snapshot_comment, "\n")
