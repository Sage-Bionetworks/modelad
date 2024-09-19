library(synapser)
library(yaml)

# Source the functions script
source("modelad/scripts/functions.R")

# Synapse login
synLogin()

# Function to read the study configuration from a YAML file
read_study_config <- function(config_file) {
  message("Reading study configuration from: ", config_file)
  tryCatch({
    config <- yaml::read_yaml(config_file)
    return(config)
  }, error = function(e) {
    message("Error reading study configuration file: ", e$message)
    return(NULL)
  })
}

# Define the path to the study configuration file
config_file <- "modelad/studies/Jax.IU.Pitt_LOAD2.PrimaryScreen/study_config.yml"

# Read the study configuration
study_config <- read_study_config(config_file)

# Extract target folder ID and data IDs from the study configuration
if (!is.null(study_config)) {
  target_folder_id <- study_config$target_folder_id
  data_ids <- study_config$data_ids
  rename_info <- study_config$rename_info
} else {
  stop("Failed to read study configuration. Script cannot proceed.")
}

# Annotations to set
annotations_list <- list(contentType = "dataset")

# Move files to the target folder and set annotations
for (data_id in data_ids) {
  tryCatch({
    move_file_to_folder(data_id, target_folder_id)
    set_annotations(data_id, annotations_list)
  }, error = function(e) {
    message("Error processing file ID ", data_id, ": ", e$message)
  })
}

# Rename specific files as needed
for (info in rename_info) {
  tryCatch({
    rename_file_if_needed(info$id, info$new_name)
  }, error = function(e) {
    message("Error renaming file ID ", info$id, ": ", e$message)
  })
}



# added 2024-08-01
# Function to create a fileview schema
create_fileview_schema <- function(name, parentId, scopeId) {
  schema <- EntityViewSchema(
    name = name,
    parent = parentId,
    scopes = scopeId,
    includeEntityTypes = list(EntityViewType$FILE),
    addDefaultViewColumns = FALSE,
    addAnnotationColumns = TRUE
  )
  fileview <- synStore(schema)
  return(fileview$properties$id)
}

# Function to query a fileview and return a dataframe
query_fileview <- function(fileviewId) {
  query_result <- synTableQuery(paste("SELECT * FROM", fileviewId))
  df <- read_csv(query_result$filepath)
  return(df)
}

# Function to read and preprocess metadata files
read_and_preprocess <- function(synId) {
  df <- read_csv(synGet(synId)$path) %>%
    mutate(across(where(is.character), as.character)) %>%
    remove_empty(c("rows", "cols"))
  return(df)
}

# Function to perform left join and handle duplicate columns
left_join_no_dup <- function(x, y, by) {
  common_columns <- setdiff(intersect(names(x), names(y)), by)

  if (length(common_columns) > 0) {
    y <- y %>%
      rename_with(~ paste0(., ".y"), all_of(common_columns))
    x <- x %>%
      rename_with(~ paste0(., ".x"), all_of(common_columns))

    result <- left_join(x, y, by = by)

    for (col in common_columns) {
      result[[col]] <- coalesce(result[[paste0(col, ".x")]], result[[paste0(col, ".y")]])
      result <- result %>% select(-all_of(paste0(col, c(".x", ".y"))))
    }
  } else {
    result <- left_join(x, y, by = by)
  }

  return(result)
}


# Create the fileview schema
fileview_id <- "syn61575683"
# create_fileview_schema("UCI_CCLines_Fileview", 'syn2580853', 'syn51713891')

# Query the fileview to get existing annotations
df <- query_fileview(fileview_id)

df$study <- study_config$study$name
df$species <- "Mouse"
df$resourceType <- "experimentalData"

df %>% glimpse

# Ensure `individualID` and `specimenID` are character type in the queried data frame
df <- df %>%
  mutate(individualID = as.character(individualID),
         specimenID = as.character(specimenID))

# Perform left join of clean_metadata with queried fileview data without duplicate columns
final_metadata <-
  left_join_no_dup(df, select_metadata,
                   by = c("individualID", "specimenID"))

# Remove empty columns and rows
final_metadata <- df %>% # final_metadata %>%
  remove_empty("cols") %>%
  distinct()

# Print final metadata for debugging
print("Final metadata after removing duplicates:")
print(head(final_metadata))
print(dim(final_metadata))




# Convert the dataframe to a Synapse table
table_final <- Table(fileview_id, final_metadata)
synStore(table_final)


