# Run all scripts in sequence
source("read_and_preprocess.R")
source("create_fileview.R")
source("query_fileview.R")
source("process_metadata.R")

# Load final coalesced metadata
load("final_metadata_coalesce.RData")

# Print final metadata for debugging
print("Final metadata coalesce after removing duplicates:")
print(head(final_metadata_coalesce))
print(dim(final_metadata_coalesce))

# Convert the dataframe to a Synapse table (coalesce join)
table_coalesce <- Table(fileview_id, final_metadata_coalesce)
synStore(table_coalesce)

# Perform a regular left join for comparison
final_metadata_left_join <- clean_metadata %>%
  left_join(df, by = c("individualID", "specimenID")) %>%
  distinct() %>%
  remove_empty("cols")

# Debugging: print preview of final_metadata_left_join after replace_na
print("Preview of final_metadata_left_join after replace_na:")
print(head(final_metadata_left_join))

# Convert the dataframe to a Synapse table (left join)
table_left_join <- Table(fileview_id, final_metadata_left_join)
synStore(table_left_join)
%>%