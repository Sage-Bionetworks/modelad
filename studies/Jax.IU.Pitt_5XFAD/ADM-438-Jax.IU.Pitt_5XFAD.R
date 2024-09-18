# https://sagebionetworks.jira.com/browse/ADM-438

# the latest version of the Jax 5XFAD individual metadata file had several empty rows. It also seems like there may be some missing rows that were there previously, since version 3 was 120KB and version 4 is 38KB.
# 1. fix the empty rows
# 2. double check whether any rows are missing that shouldn’t be?

# previous work: /Users/ryaxley/Documents/GitHub/curation/MODEL-AD/2023-05-10-Jax.IU.Pitt_5XFAD.R

library(synapser)
library(tidyverse)
library(dplyr)
library(janitor)
synLogin()

fileviewProject_id <- "syn51036997"
study_id <- "syn21983020"
study_name <- "Jax.IU.Pitt_5XFAD"

tmp <- file.path(getwd(), "tmp", study_name)
dir.create(tmp, recursive = TRUE)

columns <- c(
  Column(name = "individualID", columnType = "STRING", required = TRUE),
  Column(name = "specimenID", columnType = "STRING", required = TRUE),
  Column(name = "resourceType", columnType = "STRING", required = TRUE),
  Column(name = "metadataType", columnType = "STRING", required = TRUE),
  Column(name = "assay", columnType = "STRING", required = TRUE),
  Column(name = "dataType", columnType = "STRING", required = TRUE),
  Column(name = "fileFormat", columnType = "STRING", required = TRUE),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN", required = TRUE),
  Column(name = "isModelSystem", columnType = "BOOLEAN", required = TRUE),
  Column(name = "grant", columnType = "STRING", required = TRUE),
  Column(name = "consortium", columnType = "STRING", required = TRUE),
  Column(name = "study", columnType = "STRING", required = TRUE),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING")
)

# Configure fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = fileviewProject_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = TRUE,
  columns = columns
)
# Upload schema
schema <- synStore(schema)
fileview_id <- schema$properties$id
paste0("fileview: ", "https://www.synapse.org/#!Synapse:", fileview_id)

# query and pull annotations from Synapse and convert to a tibble
query <- paste("SELECT * FROM", fileview_id)
notes <- synTableQuery(query)$asDataFrame() %>% as_tibble()

notes %>% dim # 162 X 65
notes %>% glimpse
notes %>% view

# Download Versioned files
syn22103212_v3 <- synGet('syn22103212', version = 3, downloadLocation = tmp )
syn22103212_v4 <- synGet('syn22103212', version = 4, downloadLocation = tmp )

# Load data from files (assuming CSV format)
df_v3 <- read.csv(syn22103212_v3$path, colClasses = c("individualID" = "character"))
df_v4 <- read.csv(syn22103212_v4$path, colClasses = c("individualID" = "character"))

df_v3 %>% dim # 571 x 32
df_v4 %>% dim # 163 x 26

# remove extra column "X"
df_v4 <- select(df_v4, -X)
df_v4 %>% dim # 163 x 25

df_v3 %>% view
df_v4 %>% view

df_v3 <- janitor::remove_empty(df_v3, which = c("cols","rows") )
df_v4 <- janitor::remove_empty(df_v4, which = c("cols","rows") )

df_v3 %>% dim # 571 x 29
df_v4 %>% dim # 144 x 25

df_v3 %>% filter(duplicated(.)) # no dupes
df_v4 %>% filter(duplicated(.)) # dupes!

# remove duplicate rows
df_v4 <- df_v4 %>% unique()
df_v4 %>% dim # 72 x 25

missing_in_v4 <- setdiff(df_v3$individualID, df_v4$individualID)
added_in_v4 <- setdiff(df_v4$individualID, df_v3$individualID)
common_ids <- intersect(df_v3$individualID, df_v4$individualID)

# Output
print(paste0("IDs missing in v4 (present in v3): ", paste(missing_in_v4, collapse = ", ")))
print(paste0("IDs added in v4 (not in v3): ", paste(added_in_v4, collapse = ", ")))
print(paste0("Common IDs (present in both v3 & v4): ", paste(common_ids, collapse = ", ")))
common_ids %>% length # 72


# ij <- df_v3 %>% inner_join(df_v4, by = "individualID")
# lj <- df_v3 %>% left_join(df_v4, by = "individualID")
# rj <- df_v3 %>% right_join(df_v4, by = "individualID")
# aj <- df_v3 %>% anti_join(df_v4, by = "individualID")
# fj <- df_v3 %>% full_join(df_v4, by = "individualID")
#
# ij %>% dim
# lj %>% dim
# rj %>% dim
# aj %>% dim

df_v4$rodentDiet <- "6%" # convert to string

df_v3 <- df_v3 %>%
  rename(climbID = Climb_Identifier,
         birthID = Birth.ID,
         microchipID = Microchip.Number,
         materialOrigin = MaterialOrigin,
         stockNumber = StockNumber,
         generation = Generation,
         rodentDiet = Diet,
         rodentWeight = animalWeight,
         officialName = OfficialName
  )

matching_cols <- intersect(colnames(df_v3), colnames(df_v4))
matching_cols %>% sort
df_v3_unique_cols <- setdiff(names(df_v3), matching_cols)
df_v4_unique_cols <- setdiff(names(df_v4), matching_cols)
df_v3_unique_cols %>% sort
df_v4_unique_cols %>% sort


df_joined <- df_v3 %>%
  left_join(df_v4, by = matching_cols) %>%
  rename_with(~ str_c(.x, ifelse(duplicated(.x), '.y', '')),
              colnames(df_joined))

df_joined <- janitor::remove_empty(df_joined, which = "cols")
df_joined %>% dim
df_joined %>% view
write.csv(df_joined, file = "Jax.IU.Pitt_5XFAD_individual_metadata.csv", row.names = FALSE)

# fetch the file in Synapse, where "syn2222" is the synID of the file in Synapse
syn22103212 <- synGet('syn22103212', downloadFile=FALSE)

# save the local path to the new version of the file
syn22103212$path <- '/home/rstudio/Jax.IU.Pitt_5XFAD_individual_metadata.csv'

# add a version comment
syn22103212$versionComment <- 'Merged versions 3 and 4. Removed empty rows and columns. Removed duplicate rows. Preserved "dateDeath" and a few other legacy columns from version 3.'

# store the new file
updated_file <- synStore(syn22103212)


synStore(table(fileview_id, df_joined))

