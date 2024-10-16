library(synapser)

synLogin()

# Define the list of Synapse IDs to delete
syn_ids <- c("syn43438978",
             "syn62784392",
             "syn61586477",
             "syn60435233")

for (syn_id in syn_ids) {
  tryCatch(
    {
      synDelete(syn_id)
      cat("Successfully deleted:", syn_id, "\n")
    },
    error = function(e) {
      cat("Error deleting:", syn_id, "-", e$message, "\n")
    }
  )
}

