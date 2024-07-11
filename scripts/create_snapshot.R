# version_label <- gsub("0([1-9])", "\\1", format(Sys.Date(), "%y.%m"))

library(synapser)
library(stringr)

synLogin(silent = TRUE)

file_view_id <- "syn11346063"
# autolabel option version_label <- gsub("0([1-9])", "\\1", format(Sys.Date(), "%y.%m"))
version_label <- "24.6"
snapshot_comment <- paste(version_label, "data release")

# Retrieve entity and create snapshot
entity <- synGet(file_view_id)
cat("Creating snapshot for Synapse ID:", file_view_id, "with comment:", snapshot_comment, "\n")

if (tolower(readline(prompt = "Create snapshot? (yes/no): ")) == "yes") {
  snapshot <- synCreateSnapshotVersion(table = file_view_id, comment = snapshot_comment, label = version_label, wait = TRUE)
  cat("Snapshot created with version", snapshot$versionNumber, "\n")
} else {
  cat("Snapshot creation cancelled.\n")
}
