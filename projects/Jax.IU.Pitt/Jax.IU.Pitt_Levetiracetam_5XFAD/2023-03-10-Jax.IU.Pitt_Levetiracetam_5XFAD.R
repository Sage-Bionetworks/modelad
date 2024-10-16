library(tidyverse)
library(synapser)
library(janitor)
library(dplyr)
source('~/data-curation/MODEL-AD/coalesce_join.R')
synLogin()

grant <- "U54AG054345"
consortium <- "MODEL-AD"
study_name <- "Jax.IU.Pitt_Levetiracetam_5XFAD"
version <- "2023-03-10"
study_id <- "syn21784897"
staging_id <- "syn22096967"
individual_id <- "syn51109103"
individual_id_existing <- "syn21785645"
biospecimen_id <- "syn51109102"
assay1_id <- "syn51109101"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp",
                 paste0(version, "-", study_name))
tmp2 <- file.path(getwd(), "data-curation", consortium, "tmp",
                 paste0(version, "-", study_name,"2"))

ind <- synGet(individual_id,
              downloadLocation = tmp,
              ifcollision = "overwrite.local")$path %>% read_csv()
bio <- synGet(biospecimen_id,
              downloadLocation = tmp,
              ifcollision = "overwrite.local")$path %>% read_csv()
as1 <- synGet(assay1_id,
              downloadLocation = tmp,
              ifcollision = "overwrite.local")$path %>% read_csv()
 
ind_cols <- ind %>% colnames() %>% sort()
bio_cols <- bio %>% colnames() %>% sort()
as1_cols <- as1 %>% colnames() %>% sort()
meta_cols <- c(ind_cols, bio_cols, as1_cols) %>% sort()

ind_existing <- synGet(individual_id_existing,
              downloadLocation = tmp2,
              version = 3,
              ifcollision = "overwrite.local")$path %>% read_csv()

# dateDeath was missing from the latest individual metadata, so merged back in
ind_existing <- ind_existing %>% select(individualID, dateDeath)
 
ind <- left_join(ind, ind_existing, by="individualID", suffix=c("",".y")) %>%
  select(-ends_with(".y"))
 


# Create fileview
project <- Project("MODEL-AD-Annotations") %>% synStore()
keys <- c(
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING")
)

schema <-
  EntityViewSchema(
    name = study_name,
    parent = project$properties$id,
    scopes = study_id,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = TRUE, 
    columns = keys) %>% synStore() 
 
joined_meta <-
  ind %>%
  left_join(., bio, by = "individualID", multiple = "all") %>%
  left_join(., as1, by = "specimenID", multiple = "all") %>%
  janitor::remove_empty(c("cols","rows"))
 
write_csv(joined_meta,
          file.path(getwd(), "data-curation", consortium, "tmp",
                    paste0(version, "-", study_name),
                    "Jax.IU.Pitt_Levetiracetam_5XFAD_joined_metadata.csv"))
 
ind <- ind %>% 
  janitor::remove_empty("cols")
bio <- bio %>% 
  janitor::remove_empty("cols")
as1 <- as1 %>% 
  janitor::remove_empty("cols")
write_csv(ind,
          file.path(getwd(), "data-curation", consortium, "tmp",
            paste0(version, "-", study_name),
            "Jax.IU.Pitt_Levetiracetam_5XFAD_individual_animal_metadata_NEW.csv"))
write_csv(bio,
          file.path(getwd(), "data-curation", consortium, "tmp",
                    paste0(version, "-", study_name),
                    "Jax.IU.Pitt_Levetiracetam_5XFAD_biospecimen_metadata_NEW.csv"))
write_csv(as1,
          file.path(getwd(), "data-curation", consortium, "tmp",
                    paste0(version, "-", study_name),
                    "Jax.IU.Pitt_Levetiracetam_5XFAD_nanostring_metadata_NEW.csv"))

# Pull existing annotations from Synapse
notes <-
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$asDataFrame() %>%
  as_tibble()
notes <- notes %>% select(1:5,23:40) # 1:5,23:40
notes[notes == "NA"] <- NA
notes <- notes %>% 
  janitor::remove_empty("cols")

notes_to_push <- 
  notes %>%
  mutate(resourceType = case_when(
      str_detect(name, "metadata") ~ "metadata",
      str_detect(name, "howell") ~ "experimentalData",
      str_detect(name, "Nanostring") ~ "experimentalData",
      TRUE ~ resourceType
    )) %>%
  mutate(dataType = case_when(
      str_detect(name, "howell") ~ "geneExpression",
      str_detect(name, "Nanostring") ~ "geneExpression",
      TRUE ~ dataType
    )) %>%
  mutate(fileFormat = case_when(
    str_detect(name, "howell") ~ "csv",
    str_detect(name, "Nanostring") ~ "csv",
    TRUE ~ fileFormat
  )) %>%
  mutate(metadataType = case_when(
      str_detect(name, "individual") ~ "individual",
      str_detect(name, "biospecimen") ~ "biospecimen",
      str_detect(name, "assay") ~ "assay",
      TRUE ~ metadataType
    )) %>% 
  mutate(assay = case_when(
    str_detect(name, "howell") ~ "mRNAcounts",
    TRUE ~ assay
  )) %>% 
  mutate(modelSystemName = case_when(
    str_detect(name, "howell") ~ "5XFAD",
    str_detect(name, "Nanostring") ~ "5XFAD",
    str_detect(name, "metadata") ~ "5XFAD",
    TRUE ~ modelSystemName
  )) %>%  
  mutate(modelSystemType = case_when(
    str_detect(name, "howell") ~ "5XFAD",
    str_detect(name, "metadata") ~ "5XFAD",
    TRUE ~ modelSystemType
  ))

notes_to_push$consortium <- coalesce(notes$consortium, consortium)
notes_to_push$grant <- coalesce(notes$grant, grant)
notes_to_push$study <- coalesce(notes$study, study_name)
notes_to_push$species <- coalesce(notes$species, "Mouse")

# Push new annotations to Synapse
synStore(Table(schema$properties$id, notes_to_push))
