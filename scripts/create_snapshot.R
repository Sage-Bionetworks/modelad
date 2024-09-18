library(synapser)

synLogin(silent = TRUE)

file_view_id <- "syn11346063"
version_label <- "24.8.1" # gsub("0([1-9])", "\\1", format(Sys.Date(), "%y.%m"))
snapshot_comment <- paste(version_label, "patch release")

cat("Creating snapshot for Synapse ID:", file_view_id, "with comment:", snapshot_comment, "\n")

create_snapshot <- function(file_view_id, version_label, snapshot_comment) {
  snapshot <- synCreateSnapshotVersion(table = file_view_id, comment = snapshot_comment, label = version_label, wait = TRUE)
  cat("Snapshot created with version", version_label, "\n")
}

if (tolower(readline(prompt = "Create snapshot? (yes/no): ")) == "yes") {
  create_snapshot(file_view_id, version_label, snapshot_comment)
} else {
  cat("Snapshot creation cancelled.\n")
}

entity <- synGet(file_view_id)
cat("Current version label:", entity$properties$versionLabel, "\n")

new_version_label <- readline(prompt = "Enter the new version label (format yy.mm): ")
cat("New version label:", new_version_label, "\n")

if (tolower(readline(prompt = "Confirm creation of snapshot with this label? (yes/no): ")) == "yes") {
  snapshot_comment <- paste(new_version_label, "data release")
  create_snapshot(file_view_id, new_version_label, snapshot_comment)
} else {
  cat("Snapshot creation cancelled.\n")
}
