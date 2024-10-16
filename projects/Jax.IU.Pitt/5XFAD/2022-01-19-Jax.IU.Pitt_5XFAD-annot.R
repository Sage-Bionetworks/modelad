library(synapser)
library(synapserutils)
library(tidyverse)
library(diffdf)

# docs: SynapseR: http://127.0.0.1:30280/library/synapser/doc/synapser.html
# study: Jax.IU.Pitt_5XFAD
# synapse: https://www.synapse.org/#!Synapse:syn21983020
# github: 
# Issue: Annat Haber @ JAX updated the metadata for Jax.IU.Pitt_5XFAD
# Goals: 
# Is the latest file from Annat in the permanent location?
# Is the file named correctly or is in the working file name? If so, upload a new version with a tidy name.
# Question: Should I create a Synapse annotation set. Actually this may be better in script form. This is needed for new files.

synLogin(silent=TRUE) 
setwd('/Users/ryaxley/Work/Code/2022-01-19-Jax.IU.Pitt_5XFAD')

# Create project
project <- Project("Rich-Annotations")
project <- synStore(project)

# Study folders
study <- "Jax.IU.Pitt_5XFAD"
behavior <- "syn22001089"
clinical <- "syn22224870"
gene <- "syn22001082"
image <- "syn22094734"
immuno <- "syn22094724"
metadata <- "syn21983022"

annotation_cols <- c(
    Column(name = "assay", columnType = "STRING"),    
    Column(name = "consortium", columnType = "STRING"),
    Column(name = "grant", columnType = "STRING"),
    Column(name = "study", columnType = "STRING"),
    Column(name = "species", columnType = "STRING"),
    Column(name = "dataType", columnType = "STRING"),
    Column(name = "dataSubType", columnType = "STRING"),
    Column(name = "fileFormat", columnType = "STRING"),
    Column(name = "individualIdSource", columnType = "STRING"),
    Column(name = "metadataType", columnType = "STRING"),
    Column(name = "resourceType", columnType = "STRING"),
    Column(name = "isModelSystem", columnType = "BOOLEAN"),
    Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
    Column(name = "modelSystemType", columnType = "STRING"),
    Column(name = "modelSystemName", columnType = "STRING"),
    Column(name = "nucleicAcidSource", columnType = "STRING")
    )

# Create file view
view <- EntityViewSchema(
    name = "Jax.IU.Pitt_5XFAD",
    parent = project$properties$id,
    scopes = c(behavior, clinical, gene, image, immuno, metadata),
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE,
    columns = annotation_cols
)
view <- synStore(view)

# Import view
data <-
    synTableQuery(paste("SELECT * FROM", view$properties$id))$asDataFrame() %>%  as_tibble()
glimpse(data)



data["assay"] <- "orgsnoid"


# Import metadata
individual.staging <- synGet("syn26480975")$path %>% read_csv()
individual <- synGet("syn22103212", version=2)$path %>% read_csv() # comparing to older version before update moved to permanent location
biospecimen <- synGet("syn22103213")$path %>% read_csv()
autorad <- synGet("syn22094731")$path %>% read_csv()
rnaseq <- synGet("syn22110328")$path %>% read_csv()
imaging <- synGet("syn22094732")$path %>% read_csv()

# Compare columns
all_equal(individual, individual.staging)
janitor::compare_df_cols(individual,individual.staging)
janitor::compare_df_cols(individual.staging,individual,biospecimen,autorad,rnaseq,imaging)

diffdf::diffdf(individual.staging, individual)
# the latest file include values for the missing mice we discussed earlier


# Extract OLD file name
old_name <- individual_old$properties$name
# Check new metadata by comparing the data frames
i_old <- read_csv(individual_old$path, show_col_types = FALSE)
i_new <- read_csv(individual_new$path, show_col_types = FALSE)
# Performed update before, so also need to compare results from the versions
# Compare data frames
print(glimpse(i_old))
print(glimpse(i_new))
anti_join(i_old, i_new)
semi_join(i_old, i_new)
# Review annotations on OLD
print(individual_old$annotations)
# Download and edit annotations if needed
annot <- synGetAnnotations("syn22103212") 
# Save revised annotations
# synSetAnnotations(synID, annotation_list)
# command: file <- synStore(file)
# Since we are uploading a new version, the annotations are already in place
# Save NEW metadata content with OLD file name format
write.csv(i_new, file = paste0("temp/REVISED_", old_name), na = "", row.names = FALSE, quote = FALSE)
write.csv(i_new, file = paste0("temp/REVISED.quotes_", old_name), na = "", row.names = FALSE, quote = TRUE)
# Upload NEW metadata to OLD synID as a new version
.
# Download annotations from another metadata file
biospecimen <- "syn22103213"
b <- synGet(biospecimen)
read_csv(b$path)
b_annot <- synGetAnnotations(biospecimen)
b_annot$metadataType <- "biospecimen"
b_annot_new <- synSetAnnotations(individual_old, bio_annots)

annot.list <- list(consortium="MODEL-AD", study="Jax.IU.Pitt_5XFAD")
synSetAnnotations(individual.staging, annot.list)

# -----------------------------------------------------------
#synSetAnnotations("syn22103212", list(consortium="MODEL-AD"))
# # Overwrite annotations of entity

# # Save new filename to: "Jax.IU.Pitt_5XFAD_individual_metadata.csv"
# # ind_meta <- read_csv("files/UCI_3xTg-AD_individual_metadata.csv")
# # syncFromSynapse(individual_new, path=paste(getwd(),'temp',sep="/")) # Sync directory
# 


