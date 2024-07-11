library(tidyverse)
library(synapser)
library(synapserutils)

synLogin()

tmp <- file.path(getwd(), "data-curation", "tmp")

study_id_list <- c(
  # "syn22313528", # Jax.IU.Pitt.Proteomics_Metabolomics_Pilot	
  # "syn21983020", # Jax.IU.Pitt_5XFAD	
  "syn17095980"#, # Jax.IU.Pitt_APOE4.Trem2.R47H	
  # "syn9850001" , # Jax.IU.Pitt_APP.PS1	
  # "syn27210656", # Jax.IU.Pitt_LOAD1_Diet	
  # "syn51534997", # Jax.IU.Pitt_LOAD2	
  # "syn21784897", # Jax.IU.Pitt_Levetiracetam_5XFAD	
  # "syn22341543", # Jax.IU.Pitt_MicrobiomePilot	
  # "syn21595258", # Jax.IU.Pitt_PrimaryScreen	
  # "syn20730014", # Jax.IU.Pitt_Rat_TgF344-AD	
  # "syn21595255", # Jax.IU.Pitt_StrainValidation	
  # "syn21863375", # Jax.IU.Pitt_Verubecestat_5XFAD	
  # "syn18693211", # Jax.IU.Pitt_hTau_Trem2	
  # "syn15811463", # MODEL-AD_JAX_GWAS_Gene_Survey
  # "syn22964685", # UCI_3xTg-AD	
  # "syn16798076", # UCI_5XFAD	
  # "syn27207345", # UCI_ABCA7	
  # "syn26943727", # UCI_ABI3	
  # "syn50944316", # UCI_BIN1	
  # "syn22341542", # UCI_Microbiome	
  # "syn25316706", # UCI_PrimaryScreen	
  # "syn26943950", # UCI_Trem2-R47H_NSS	
  # "syn50670633", # UCI_Trem2_Cuprizone	
  # "syn18634479"  # UCI_hAbeta_KI	
)


# Create a list of column names
column_list <- c(
  # Identifiers
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "microchipID", columnType = "STRING"),
  Column(name = "birthID", columnType = "STRING"),
  Column(name = "matingID", columnType = "STRING"),

  # Study
  Column(name = "study", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),

  # Biological
  Column(name = "species", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "genotypeBackground", columnType = "STRING"),
  Column(name = "individualCommonGenotype", columnType = "STRING"),
  Column(name = "individualIdSource", columnType = "STRING"),
  Column(name = "materialOrigin", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "DOUBLE"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "generation", columnType = "STRING"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "waterpH", columnType = "DOUBLE"),
  Column(name = "brainWeight", columnType = "DOUBLE"),
  Column(name = "rodentWeight", columnType = "DOUBLE"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "room", columnType = "STRING"),

  # Experimental Information
  Column(name = "officialName", columnType = "STRING", maximumSize = "100"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "dateDeath", columnType = "DATE"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN")
)

# Create a fileview schema
schema <- EntityViewSchema(
  name = "MODEL-AD",
  parent = "syn51036997", # MODEL-AD Annotations
  scopes = study_id_list, # Models and Model Annotations
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = column_list
)

# drop_column_list <- c(
#   # Identifiers
#   Column(name = "description", columnType = "STRING"),
#   Column(name = "createdBy", columnType = "DATE"),
#   Column(name = "parentId", columnType = "STRING")#,
#   # Column(name = "microchipID", columnType = "STRING"),
#   # Column(name = "birthID", columnType = "STRING"),
#   # Column(name = "matingID", columnType = "STRING"),
# ) 
# # Remove the createdOn and modifiedOn columns from the schema
# schema$removeColumn(drop_column_list)

# Try to store the schema
tryCatch({
  schema <- synStore(schema)
  fileview_id <- schema$properties$id
}, error = function(e) {
  stop(e)
})

# Pull existing annotations from Synapse
query <-
  synTableQuery(paste("SELECT * FROM", fileview_id), resultsAs="csv")$filepath %>%
  read_csv()

query %>% 
  select(id, name, study, resourceType, metadataType, dataType )%>% 
  filter(str_detect(name, "metadata"))


query2 = synTableQuery("SELECT * FROM syn11346063 WHERE ( ( \"metadataType\" = 'assay' OR \"metadataType\" = 'biospecimen' OR \"metadataType\" = 'individual' ) AND ( \"study\" HAS ( 'Jax.IU.Pitt_APP.PS1', 'MODEL-AD_JAX_GWAS_Gene_Survey', 'UCI_5XFAD', 'Jax.IU.Pitt_APOE4.Trem2.R47H', 'UCI_hAbeta_KI', 'Jax.IU.Pitt_PrimaryScreen', 'Jax.IU.Pitt_StrainValidation', 'Jax.IU.Pitt_hTau_Trem2', 'Jax.IU.Pitt_5XFAD', 'UCI_3xTg-AD', 'UCI_PrimaryScreen', 'UCI_Trem2-R47H_NSS', 'UCI_Trem2_Cuprizone' ) ) )", resultsAs="csv")$filepath %>%
  read_csv()

query2 %>% 
  select(id, name, study, resourceType, metadataType, dataType ) %>% 
  filter(str_detect(name, "metadata")) %>% 
  filter(str_detect(study, "5XFAD|Trem2")) %>% 
  arrange(study,metadataType)


# This is a revised version of Jared's query
query2 <- synTableQuery("SELECT
  id,
  name,
  study,
  resourceType,
  metadataType,
  dataType
FROM
  syn11346063
WHERE
  ( study IN (
            'Jax.IU.Pitt_APP.PS1',
      'MODEL-AD_JAX_GWAS_Gene_Survey',
      'UCI_5XFAD',
      'Jax.IU.Pitt_APOE4.Trem2.R47H',
      'UCI_hAbeta_KI',
      'Jax.IU.Pitt_PrimaryScreen',
      'Jax.IU.Pitt_StrainValidation',
      'Jax.IU.Pitt_hTau_Trem2',
      'Jax.IU.Pitt_5XFAD',
      'UCI_3xTg-AD',
      'UCI_PrimaryScreen',
      'UCI_Trem2-R47H_NSS',
      'UCI_Trem2_Cuprizone'
    )
  )")$filepath %>%
  read_csv() #%>%
  
# filter(str_detect(name, "metadata")) #%>%
  # filter(str_detect(study, "5XFAD|Trem2")) %>%
  # arrange(study, metadataType)




	

