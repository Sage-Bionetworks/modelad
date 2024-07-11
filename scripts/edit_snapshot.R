library(synapser)

synLogin(silent = TRUE)

# https://www.synapse.org/#!Synapse:syn11346063
file_view_id <- "syn11346063"
version_number <- "55"
new_comment <- "24.6 data release"
new_label

snapshot <- synGet(file_view_id, version = version_number)
snapshot$versionComment <- new_comment

snapshot$properties$versionComment <- new_)comment

synStore(snapshot)

cat("Comment updated to: ", new_comment, "\n")

# Retrieve and print the updated snapshot to verify
snapshot <- synGetSnapshotVersion(file_view_id, versionNumber = version_number)
snapshot$properties$versionLabel



