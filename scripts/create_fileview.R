installsource("modelad/scripts/synapse_manager.R")

# Initialize SynapseManager
synManager <- SynapseManager$new()

# Create the fileview schema
fileview_id <- createFileviewSchema(
  name = "MODEL-AD",
  parentId = 'syn2580853',
  scopeId = c('syn51713891','syn27207345')
)

# Save fileview ID
save(fileview_id, file = "fileview_id.RData")

--
# Load necessary libraries
library(synapser)
library(dplyr)
library(readr)
library(janitor)

# Function to initialize Synapse
initialize_synapse <- function() {
  synLogin()
}

# # Function to create a fileview schema
# create_fileview_schema <- function(name, parentId, scopeId) {
#   schema <- EntityViewSchema(
#     name = name,
#     parent = parentId,
#     scopes = scopeId,
#     includeEntityTypes = list(EntityViewType$FILE),
#     addDefaultViewColumns = FALSE,
#     addAnnotationColumns = TRUE
#   )
#   fileview <- synStore(schema)
#   return(fileview$properties$id)
# }
#
# # Function to query a fileview and return a dataframe
# query_fileview <- function(fileviewId) {
#   query_result <- synTableQuery(paste("SELECT * FROM", fileviewId))
#   df <- read_csv(query_result$filepath) %>%
#     clean_names()  # Clean column names using janitor
#   return(df)
# }
#
# # Function to read and preprocess metadata files
# read_and_preprocess <- function(synId) {
#   df <- read_csv(synGet(synId)$path) %>%
#     mutate(across(where(is.character), as.character)) %>%
#     remove_empty(c("rows", "cols"))
#   return(df)
# }
#
# # Function to perform left join and handle duplicate columns
# left_join_no_dup <- function(x, y, by) {
#   common_columns <- setdiff(intersect(names(x), names(y)), by)
#
#   if (length(common_columns) > 0) {
#     y <- y %>%
#       rename_with(~ paste0(., ".y"), all_of(common_columns))
#     x <- x %>%
#       rename_with(~ paste0(., ".x"), all_of(common_columns))
#
#     result <- left_join(x, y, by = by)
#
#     for (col in common_columns) {
#       result[[col]] <- coalesce(result[[paste0(col, ".x")]], result[[paste0(col, ".y")]])
#       result <- result %>% select(-all_of(paste0(col, c(".x", ".y"))))
#     }
#   } else {
#     result <- left_join(x, y, by = by)
#   }
#
#   return(result)
# }
#
# # Function to create and upload a Synapse table from a dataframe
# create_and_upload_synapse_table <- function(name, parentId, scopeId, final_metadata) {
#   # Create the fileview schema
#   fileview_id <- create_fileview_schema(name, parentId, scopeId)
#
#   # Convert the dataframe to a Synapse table
#   table_final <- Table(fileview_id, final_metadata)
#   synStore(table_final)
#
#   return(fileview_id)
# }
#
# # Function to download and preprocess metadata, join and clean the data
# prepare_metadata <- function(individual_metadata_synId, biospecimen_metadata_synId, assay_metadata_synId) {
#   # Download and preprocess metadata files
#   individual_metadata <- read_and_preprocess(individual_metadata_synId)
#   biospecimen_metadata <- read_and_preprocess(biospecimen_metadata_synId)
#   assay_metadata <- read_and_preprocess(assay_metadata_synId)
#
#   # Ensure `individualID` and `specimenID` are character type
#   individual_metadata <- individual_metadata %>%
#     mutate(individualID = as.character(individualID))
#
#   biospecimen_metadata <- biospecimen_metadata %>%
#     mutate(individualID = as.character(individualID), specimenID = as.character(specimenID))
#
#   assay_metadata <- assay_metadata %>%
#     mutate(specimenID = as.character(specimenID))
#
#   # Perform left joins without duplicate columns
#   combined_metadata <- left_join_no_dup(assay_metadata, biospecimen_metadata, by = "specimenID") %>%
#     left_join_no_dup(individual_metadata, by = "individualID")
#
#   # Remove all empty columns and rows from combined_metadata
#   clean_metadata <- combined_metadata %>%
#     select(where(~ !all(is.na(.)))) %>%
#     filter(rowSums(is.na(.)) != ncol(.))
#
#   # Add the study column to clean_metadata
#   clean_metadata <- clean_metadata %>%
#     mutate(study = "UCI_CCLines")
#
#   return(clean_metadata)
# }
#
# # Initialize Synapse
# initialize_synapse()
#
# # Define Synapse IDs for metadata files
# individual_metadata_synId <- 'syn53470893'
# biospecimen_metadata_synId <- 'syn53470890'
# assay_metadata_synId <- 'syn53470889'
#
# # Prepare metadata
# final_metadata <- prepare_metadata(individual_metadata_synId, biospecimen_metadata_synId, assay_metadata_synId)
#
# # Create and upload the Synapse table
# fileview_id <- create_and_upload_synapse_table("UCI_CCLines_Fileview", 'syn2580853', 'syn51713891', final_metadata)
#
# # Query the fileview to verify
# queried_metadata <- query_fileview(fileview_id)
#
# # Print final metadata for debugging
# print("Queried metadata after upload:")
# print(head(queried_metadata))
# print(dim(queried_metadata))
