library(tidyverse)
library(synapser)
library(janitor)
source("functions/coalesce_join.R")
synLogin()
# [ADEL49](https://sagebionetworks.jira.com/browse/ADEL-49)

# Set up variables
study_name <- "Jax.IU.Pitt_LOAD2"
version <- "2023-05-23"
grant <- "U54AG054345"
consortium <- "MODEL-AD"
study_id <- "syn51534997"
staging_id <- "syn51535045"
data_id <- "syn51535520"

# Create a temporary directory
tmp <- file.path(getwd(), consortium, "tmp", study_name)
dir.create(tmp, recursive = TRUE)
       
# Create a list of column names
column_list <- c(
  # Identifiers
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING")
)
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
# Create a fileview schema
schema <-
  EntityViewSchema(
    name = study_name,
    parent = "syn51036997",
    scopes = study_id,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = FALSE,
    addAnnotationColumns = FALSE
    # columns = keys
  ) %>% synStore() 

schema$addColumns("individualId")
schema %>% synStore()
# Pull existing annotations from Synapse
df <-
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$filepath %>%
  read_csv() %>% 
  select(1,4,5)

write.csv(df$name %>% sort() , file.path(tmp, "filelist.csv"))


# Categorize file types with assay-specific folders
metadata_ids <- df %>%
  filter(str_detect(name, "metadata|key|assay|manifest")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(metadata_ids$id, ~synMove(.x, "syn51745755"))

# Behavior Process
behavioral_ids <- df %>%
  filter(str_detect(name, "wheel|spontaneous|rotarod|field|frailty")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(behavioral_ids$id, ~synMove(.x, "syn51745788"))  

# Immunoassay (Electrochemiluminescence)
electrochem_ids <- df %>%
  filter(str_detect(name, "proinflam")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(electrochem_ids$id, ~synMove(.x, "syn51745781"))  

# Metabolomics / Metabolomics (Biocrates Q500)
metabolomics_ids <- df %>%
  filter(str_detect(name, "Q500")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(metabolomics_ids$id, ~synMove(.x, "syn51748055")) 

# Proteomics / Proteomics (TMT quantification)
proteomics_ids <- df %>%
  filter(str_detect(name, "TMT")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(proteomics_ids$id, ~synMove(.x, "syn51745781"))  

# Gene Expression / Gene Expression (RNA seq) / FASTQ
fastq_ids <- df %>%
  filter(str_detect(name, "fastq.gz")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(fastq_ids$id, ~synMove(.x, "syn51748057"))  

# Gene Expression / Gene Expression (RNA seq) / FASTQ
rnaseq_ids <- df %>%
  filter(str_detect(name, "rnaseq")) %>%
  select(id) %>%
  as.list()
furrr::future_walk(rnaseq_ids$id, ~synMove(.x, "syn51748058"))  

# Pull files
manifest <- synGet("syn51708694", downloadLocation = tmp)$path %>% read_tsv()
ids <- synGet("syn51441046", downloadLocation = tmp)$path %>% read_csv()

# annotate files with individualID and specimenIDs only

manifest <- manifest %>% 
  remove_empty("cols") %>% 
  mutate(name = basename(path)) %>% 
  select(individualID, specimenID, name)

df <- df %>% 
  left_join(manifest) %>% 
  left_join(ids)
  
# Push annotations to Synapse
synStore(Table(schema$properties$id, df))

# ind_meta synGet("syn34228037", downloadLocation = tmp)$path %>% read_csv()
# bio_meta synGet("syn34228034", downloadLocation = tmp)$path %>% read_csv()
