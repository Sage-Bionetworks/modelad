# Load the synapser package
library(synapser)

# Authenticate with Synapse
synLogin()

# Define the Synapse ID of the File View and snapshot comment
file_view_id <- "syn11346063"
snapshot_comment <- "24.6 data release"

# Create the snapshot using synCreateSnapshotVersion
snapshot <- synCreateSnapshotVersion(file_view_id, comment = snapshot_comment)

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

# Assign the DOI using synSetAnnotations
annotations <- list(
  doi = TRUE,
  doiTitle = snapshot_comment,
  doiAuthors = "Sage Bionetworks",
  doiType = "Collection"
)

synSetAnnotations(entity = file_view_id, annotations = annotations, version = snapshot_version)

# Print confirmation
cat("DOI assigned to snapshot version", snapshot_version, "with title:", snapshot_comment, "\n")
