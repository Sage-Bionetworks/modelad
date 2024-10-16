library(synapser)
library(dplyr)
library(readr)
library(janitor)
library(synapserutils)

# Function to initialize Synapse
initialize_synapse <- function() {
  synLogin()
}


# download metadata folder
system("synapse get -r syn51713897")





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

# Initialize Synapse
initialize_synapse()

# Define Synapse IDs for metadata files
individual_metadata_synId <- 'syn53470893'
biospecimen_metadata_synId <- 'syn53470890'
assay_metadata_synId <- 'syn53470889'

# Download and preprocess metadata files
individual_metadata <- read_and_preprocess(individual_metadata_synId)
biospecimen_metadata <- read_and_preprocess(biospecimen_metadata_synId)
assay_metadata <- read_and_preprocess(assay_metadata_synId)

# Ensure `individualID` and `specimenID` are character type
individual_metadata <- individual_metadata %>%
  mutate(individualID = as.character(individualID))

biospecimen_metadata <- biospecimen_metadata %>%
  mutate(individualID = as.character(individualID), specimenID = as.character(specimenID))

assay_metadata <- assay_metadata %>%
  mutate(specimenID = as.character(specimenID))

# Perform left joins without duplicate columns
combined_metadata <- left_join_no_dup(assay_metadata, biospecimen_metadata, by = "specimenID") %>%
  left_join_no_dup(individual_metadata, by = "individualID")

# Remove all empty columns and rows from combined_metadata
clean_metadata <- combined_metadata %>%
  select(where(~ !all(is.na(.)))) %>%
  filter(rowSums(is.na(.)) != ncol(.))


# Curation corrections

# Add the study column to df
clean_metadata$study #<- "UCI_CCLines"
# Drop the libraryID column from df

select_metadata <- clean_metadata %>%
  select(c(
  "individualID",
  "specimenID"))


# Create the fileview schema
fileview_id <- create_fileview_schema("UCI_CCLines_Fileview", 'syn2580853', 'syn51713891')

# Query the fileview to get existing annotations
df <- query_fileview(fileview_id)

# Ensure `individualID` and `specimenID` are character type in the queried data frame
df <- df %>%
  mutate(individualID = as.character(individualID),
         specimenID = as.character(specimenID))

# Perform left join of clean_metadata with queried fileview data without duplicate columns
final_metadata <-
  left_join_no_dup(df, select_metadata,
                   by = c("individualID", "specimenID"))

# Remove empty columns and rows
final_metadata <- final_metadata %>%
  remove_empty("cols") %>%
  distinct()

# Print final metadata for debugging
print("Final metadata after removing duplicates:")
print(head(final_metadata))
print(dim(final_metadata))


final_metadata$study <- "UCI_CCLines"

# Convert the dataframe to a Synapse table
table_final <- Table(fileview_id, final_metadata)
synStore(table_final)

