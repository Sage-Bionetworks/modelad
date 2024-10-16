library(tidyverse)
library(synapser)
library(janitor)
synLogin()

grant <- "U54AG054345"
consortium <- "MODEL-AD"
study_name <- "Jax.IU.Pitt_Levetiracetam_5XFAD"
version <- "2023-05-08"
study_id <- "syn21784897"
individual_id <- "syn21785645"
biospecimen_id <- "syn51231269"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp", study_name)

ind <- synGet(individual_id, version = 4,
              downloadLocation = file.path(tmp, "v4"), 
              ifcollision = "overwrite.local")$path %>% read_csv()

ind2 <- synGet(individual_id, version = 2,
              downloadLocation = file.path(tmp, "v2"), 
              ifcollision = "overwrite.local")$path %>% read_csv()

bio <- synGet(biospecimen_id, version = 1,
              downloadLocation = file.path(tmp, "v1"), 
              ifcollision = "overwrite.local")$path %>% read_csv()              
               
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
  Column(name = "individualIdSource", columnType = "STRING"),
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
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "dateDeath", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "genotypeBackground", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "officialName", columnType = "STRING"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "waterpH", columnType = "INTEGER"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "INTEGER"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "ageBirth", columnType = "INTEGER"),
  Column(name = "individualCommonGenotype", columnType = "STRING")
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

# Pull existing annotations from Synapse
query <- paste("SELECT * FROM", schema$properties$id)
results <- synTableQuery(query, resultsAs="csv")$filepath %>% read_csv()
results[results == "NA"] <- NA

notes <- 
  results %>% select(1:5,individualID,specimenID,study,organ,tissue)

# 1. Fix study name to "Jax.IU.Pitt_Levetiracetam_5XFAD"
notes$study <- study_name 

# 2. Add organ and tissue annotations to all the files
notes %>% filter(str_detect(name, "PK")) #%>% coalesce()
  # organ = c("blood","brain","plasma")
  #   mutate(modelSystemName = coalesce(modelSystemName.x, modelSystemName.y),
  #        sex = coalesce(sex.x, sex.y),
  #        species = coalesce(species.x, species.y)) %>% 


notes %>% select(name,organ) %>% view




results <- results %>% janitor::remove_empty("cols")



# Push new annotations to Synapse
synStore(Table(schema$properties$id, notes))
  









# I also noticed that the assay metadata is missing the assay name, so it would be nice to have that added as well.
