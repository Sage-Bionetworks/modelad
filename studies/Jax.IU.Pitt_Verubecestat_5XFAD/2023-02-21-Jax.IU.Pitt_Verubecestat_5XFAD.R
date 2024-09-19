library(tidyverse)
library(furrr)
library(janitor)
library(synapser)
library(readr)
library(dplyr)
library(lubridate)
source('~/data-curation/MODEL-AD/coalesce_join.R')
synLogin()

# Synapse folders
study_id <- "syn21863375"
data_id <- "syn26428682"
staging_id <- "syn23628033"
individual_id <- "syn22251788" #"syn51109100"
# individual_id_old <- "syn22251788"
biospecimen_id <- "syn26136407" #"syn51109099"
assay1_id <- "syn51109098" # nanostring
# assay2_id <- "" 

# Setting
consortium <- "MODEL-AD"
grant <- "U54AG054345"
study <- "Jax.IU.Pitt_Verubecestat_5XFAD"
version <- "2023-02-21"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp",
                 paste0(version, "-", study))
# tmp2 <- file.path(getwd(), "data-curation", consortium, "tmp",
#                  paste0(version, "-", study, "-2"))

ind <- synGet(individual_id,
              downloadLocation = tmp,
              ifcollision = "overwrite.local")$path %>% read_csv()
bio <- synGet(biospecimen_id,
              downloadLocation = tmp,
              ifcollision = "overwrite.local")$path %>% read_csv()
as1 <- synGet(assay1_id, 
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

# ind_v2 <- synGet(individual_id_old,
#               downloadLocation = tmp2, 
#               version = 2, 
#               ifcollision = "overwrite.local")$path %>% read_csv()

# ind_cols <- ind %>% colnames()
# bio_cols <- bio %>% colnames()
# as1_cols <- as1 %>% colnames()
# meta_cols <- c(ind_cols, bio_cols, as1_cols) %>% sort()


# dateDeath was missing from the latest individual metadata, so merged back in
# ind_v2 <- ind_v2 %>% select(individualID, dateDeath)
# 
# ind <- left_join(ind, ind_v2, by="individualID", suffix=c("",".y")) %>% 
#   select(-ends_with(".y"))
# 
# filename <- 
#   file.path(getwd(), "data-curation", consortium, "tmp",
#           paste0(version, "-", study), 
#           "Jax.IU.Pitt_Verubecestat_5XFAD_individual_metadata.csv")
# write_csv(ind, filename)



# Create fileview
project <- Project("MODEL-AD-Annotations") %>% synStore()
keys <- c(
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "INTEGER"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "bindingDensity", columnType = "DOUBLE"),
  Column(name = "birthID", columnType = "STRING"),
  Column(name = "brainWeight", columnType = "STRING"),
  Column(name = "BrodmannArea", columnType = "STRING"),
  Column(name = "cellType", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "DV200", columnType = "STRING"),
  Column(name = "fastingState", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "generation", columnType = "STRING"),
  Column(name = "geneRLF", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "genotypeBackground", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "individualCommonGenotype", columnType = "STRING"),
  Column(name = "individualIdSource", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "isPostMortem", columnType = "BOOLEAN"),
  Column(name = "isStranded", columnType = "BOOLEAN"),
  Column(name = "libraryBatch", columnType = "STRING"),
  Column(name = "libraryID", columnType = "STRING"),
  Column(name = "libraryPrep", columnType = "STRING"),
  Column(name = "libraryPreparationMethod", columnType = "STRING"),
  Column(name = "libraryVersion", columnType = "STRING"),
  Column(name = "materialOrigin", columnType = "STRING"),
  Column(name = "matingID", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "microchipID", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "nanostringBatch", columnType = "STRING"),
  Column(name = "nucleicAcidSource", columnType = "STRING"),
  Column(name = "officialName", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "platform", columnType = "STRING"),
  Column(name = "readLength", columnType = "STRING"),
  Column(name = "readStrandOrigin", columnType = "STRING"),
  Column(name = "referenceSet", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "RIN", columnType = "STRING"),
  Column(name = "rnaBatch", columnType = "STRING"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "rodentWeight", columnType = "STRING"),
  Column(name = "room", columnType = "STRING"),
  Column(name = "runType", columnType = "STRING"),
  Column(name = "sampleStatus", columnType = "STRING"),
  Column(name = "samplingAge", columnType = "DOUBLE"),
  Column(name = "samplingAgeUnits", columnType = "STRING"),
  Column(name = "sequencingBatch", columnType = "STRING"),
  Column(name = "sex", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"),
  Column(name = "specimenIdSource", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "tissueVolume", columnType = "STRING"),
  Column(name = "tissueWeight", columnType = "DOUBLE"),
  Column(name = "totalReads", columnType = "STRING"),
  Column(name = "treatmentDose", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "validBarcodeReads", columnType = "STRING"),
  Column(name = "visitNumber", columnType = "INTEGER"),
  Column(name = "waterpH", columnType = "STRING")
)

schema <-
  EntityViewSchema(
    name = study,
    parent = project$properties$id,
    scopes = study_id,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE,
    columns = keys) %>% synStore()

# schema2 <-
#   EntityViewSchema(
#     name = "NanoString",
#     parent = project$properties$id,
#     scopes = c("syn22001120", "syn51106299"),
#     includeEntityTypes = c(EntityViewType$FILE),
#     addDefaultViewColumns = TRUE,
#     addAnnotationColumns = FALSE,
#     columns = keys#,
#     #ignoredAnnotationColumnNames = list("individualID")
#   ) %>% synStore()

joined_meta <-
  ind %>% 
  left_join(., bio, by = "individualID", multiple = "all") %>% 
  left_join(., as1, by = "specimenID", multiple = "all") %>%
  remove_empty("cols") 

write_csv(joined_meta, 
          file.path(getwd(), "data-curation", consortium, "tmp",
                    paste0(version, "-", study),
                    "Jax.IU.Pitt_Verubecestat_5XFAD_joined_metadata.csv"))

# Pull existing annotations from Synapse
notes <- 
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$asDataFrame() %>% 
  as_tibble()
notes <- notes %>% select(1:3,4:5,23:95)
notes[notes == "NA"] <- NA
notes <- notes %>% remove_empty("cols")

notes_to_push <- notes %>%
  mutate(
    resourceType = case_when(
      str_detect(name, "metadata") ~ "metadata",
      str_detect(name, "run\\s\\d+\\ssummary") ~ "experimentalData",
      str_detect(name, "Nanostring") ~ "experimentalData",
      TRUE ~ resourceType
  )) %>%
  mutate(
    dataType = case_when(
      str_detect(name, "run\\s\\d+\\ssummary") ~ "geneExpression",
      str_detect(name, "Nanostring") ~ "geneExpression",
      TRUE ~ dataType
  )) %>%
  mutate(assay = case_when(
    str_detect(name, "run\\s\\d+\\ssummary") ~ "mRNAcounts",
    str_detect(name, "Nanostring") ~ "mRNAcounts",
    str_detect(name, "ver.alldata") ~ "pharmacokinetics",
    TRUE ~ assay
  )) %>%
  mutate(fileFormat = case_when(
    str_detect(name, "run\\s\\d+\\ssummary") ~ "csv",
    str_detect(name, "Nanostring") ~ "csv",
    TRUE ~ fileFormat
  )) %>%
  mutate(modelSystemName = case_when(
    str_detect(name, "run\\s\\d+\\ssummary") ~ "5XFAD",
    str_detect(name, "Nanostring") ~ "5XFAD",
    str_detect(name, "metadata") ~ "5XFAD",
    TRUE ~ modelSystemName
  )) %>%
  mutate(
    metadataType = case_when(
      str_detect(name, "individual") ~ "individual",
      str_detect(name, "biospecimen") ~ "biospecimen",
      str_detect(name, "assay") ~ "assay",
      TRUE ~ metadataType
  ))

synStore(Table(schema$properties$id, notes_to_push))
