library(synapser)
library(synapserutils)
library(tidyverse)
library(diffdf)

# docs: SynapseR: http://127.0.0.1:30280/library/synapser/doc/synapser.html
# Goals: Test setting annotations programmatically. Several new datasets will
# start coming in a couple weeks and I want to be able to efficiently annotate files.
# Q: Should I create a generic Synapse annotation set for new files and manually edit the notes? Or, should I edit completely in R?

synLogin(silent = TRUE)
setwd("/Users/ryaxley/Work/Code/2022-01-25-UCI_5XFAD/")

# Create project
project <- Project("Rich-Annotations")
project <- synStore(project)

# UCI_5XFAD folders
behavior <- "syn17096067"
electrophysiology <- "syn21296203"
rnaSeq <- "syn16798181"
immunoassay <- "syn20824020"
metadata <- "syn16798173"

annotation_cols <- c(
    Column(name = "consortium", columnType = "STRING"),
    Column(name = "study", columnType = "STRING"),
    Column(name = "assay", columnType = "STRING"),
    Column(name = "dataType", columnType = "STRING"),
    Column(name = "dataSubType", columnType = "STRING"),
    Column(name = "fileFormat", columnType = "STRING"),
    Column(name = "individualIdSource", columnType = "STRING"),
    Column(name = "metadataType", columnType = "STRING"),
    Column(name = "nucleicAcidSource", columnType = "STRING"),
    Column(name = "resourceType", columnType = "STRING"),
    Column(name = "isModelSystem", columnType = "BOOLEAN"),
    Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
    Column(name = "modelSystemType", columnType = "STRING")
)

# Create file view
view <- EntityViewSchema(
    name = "UCI_5XFAD",
    parent = project$properties$id,
    scopes = c(metadata, behavior, electrophysiology, rnaSeq, immunoassay),
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

# Filter data types for annotating
# TESTING - Filter file view based on file/folder/individualID/? types
annotSet <-
    c(
        "id",
        "name",
        "type",
        "parentId",
        "dataFileHandleId",
        "consortium",
        "study",
        "assay",
        "dataType",
        "resourceType",
        "isMultiSpecimen",
        "individualID",
        "specimenID"#,
        # "fileFormat",
        # "grant",
        # "group"
    )
filter(data, parentId == metadata)
data %>% filter(str_detect(name, ".csv$")) %>% select(annotSet) %>% print(n=40) %>% glimpse()
data %>% filter(str_detect(name, ".pdf$")) %>% select(annotSet)
data %>% filter(str_detect(name, ".bam$")) %>% select(annotSet)
data %>% filter(str_detect(name, "LTP")) %>% select(annotSet)
data %>% filter(str_detect(assay, "rnaSeq"))  %>% select(annotSet) %>% print(n=40)

# Import metadata
individual.staging <- synGet("syn26321588")$path %>% read_csv()
individual <- synGet("syn18880070")$path %>% read_csv()
biospecimen <- synGet("syn18876530")$path %>% read_csv()
assay <- synGet("syn18876537")$path %>% read_csv()

# Compare columns
spec(individual.staging)
dplyr::all_equal(individual, individual.staging)
janitor::compare_df_cols(individual.staging,individual,biospecimen,assay)
diffdf::diffdf(individual.staging, individual)
# the latest file include values for the missing mice we discussed earlier

# Metadata
ind <- individual %>%
    mutate(individualID = as.character(individualID)) %>%
    select(individualID, modelSystemName, sex, species)
bio <- biospecimen %>%
    mutate(individualID = as.character(individualID)) %>%
    select(specimenID, nucleicAcidSource, organ, tissue)
asy <- assay %>%
    select(specimenID, libraryPrep, platform, readLength, runType)


# Join file view with validated metadata
coalesce(data, ind, by = 'individualID')
coalesce(data, bio, by = 'specimenID')
coalesce(data, asy, by = 'specimenID')
coalesce(bio, asy, by = 'specimenID')

    
# # Create a view of UCI_3xTg-AD
# view3 <- EntityViewSchema(name = "View-UCI_3xTg-AD",
#                              columns = c(Column(name = "program", columnType = "STRING"),
#                                          Column(name = "grant", columnType = "STRING"),
#                                          Column(name = "study", columnType = "STRING"),
#                                          Column(name = "consortium", columnType = "STRING"),
#                                          Column(name = "assay", columnType = "STRING"),
#                                          Column(name = "species", columnType = "STRING"),
#                                          Column(name = "fileFormat", columnType = "STRING"),
#                                          Column(name = "dataType", columnType = "STRING"),
#                                          Column(name = "metadataType", columnType = "STRING"),
#                                          Column(name = "resourceType", columnType = "STRING"),
#                                          Column(name = "isModelSystem", columnType = "BOOLEAN"),
#                                          Column(name = "modelSystemType", columnType = "STRING")),
#                              parent = project$properties$id,
#                              scopes = "syn22964685",
#                              includeEntityTypes = c(EntityViewType$FILE),
#                              add_default_columns = FALSE)
# view3 <- synStore(view3)
# queryResults <- synTableQuery(sprintf("select * from %s", view3$properties$id))


