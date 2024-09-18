library(tidyverse)
library(synapser)
library(synapserutils)
library(janitor)

# [ADEL62](https://sagebionetworks.jira.com/browse/ADEL-62)
synLogin()

# Set up variables
consortium <- "MODEL-AD"
grant <- "U54AG054349"
study_name <- "UCI_Bin1K358R"
version <- "2023-06-26"
study_id <- "syn50944316" # [syn50944316](https://www.synapse.org/#!Synapse:syn50944316)
staging_id <- "syn50944318"
data_id <- "syn51754004"
fileviewProject_id <- "syn51036997"

       
minimum_annotation_set <- c(
  # Column(name = "name", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING")
)

# Configure and upload the annotation fileview
schema <- EntityViewSchema(
  name = study_name,
  parent = fileviewProject_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = minimum_annotation_set
) %>% synStore()

# Pull existing annotations from Synapse
df <-
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$filepath %>%
  read_csv()

# Review annotations ans see what is missing 
df %>% 
  select(5,24:35) %>% 
  view()

# Categorize file types 
df %>%
  select(5,24:35) %>% 
  filter(str_detect(name, "metadata|key|assay|manifest"))

df$study


# Push annotations to Synapse
synStore(Table(schema$properties$id, df))

# Pull metadata files
manifest1 <- synGet("syn51747941")$path %>% read_tsv()
manifest2 <- synGet("syn52283008")$path %>% read_tsv()
ind <- synGet("syn51747927")$path %>% read_csv()
bio <- synGet("syn51747924")$path %>% read_csv()
rnaSeq <- synGet("syn51747930")$path %>% read_csv()
scRnaSeq <- synGet("syn52283007")$path %>% read_csv()


left_join(ind,bio) %>% 
  janitor::remove_empty("cols") %>% 
  view
# Merge manifests
merge(manifest1, manifest2, by = "") %>% view
manifest1 %>% view
# manifest <- manifest %>% 
#   remove_empty("cols") %>% 
#   mutate(name = basename(path)) %>% 
#   select(individualID, specimenID, name)

df <- df %>% 
  left_join(manifest) %>% 
  left_join(ids)



# ind_meta synGet("syn34228037", downloadLocation = tmp)$path %>% read_csv()
# bio_meta synGet("syn34228034", downloadLocation = tmp)$path %>% read_csv()