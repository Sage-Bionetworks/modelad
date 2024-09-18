library(tidyverse)
library(synapser)
library(furrr)
#library(synapserutils)
synLogin()


coalesce_join <- function(x, y, 
                          by = NULL, suffix = c(".x", ".y"), 
                          join = dplyr::full_join, ...) {
  joined <- join(x, y, by = by, suffix = suffix, ...)
  # names of desired output
  cols <- union(names(x), names(y))
  
  to_coalesce <- names(joined)[!names(joined) %in% cols]
  suffix_used <- suffix[ifelse(endsWith(to_coalesce, suffix[1]), 1, 2)]
  # remove suffixes and deduplicate
  to_coalesce <- unique(substr(
    to_coalesce, 
    1, 
    nchar(to_coalesce) - nchar(suffix_used)
  ))
  
  coalesced <- purrr::map_dfc(to_coalesce, ~dplyr::coalesce(
    joined[[paste0(.x, suffix[1])]], 
    joined[[paste0(.x, suffix[2])]]
  ))
  names(coalesced) <- to_coalesce
  
  dplyr::bind_cols(joined, coalesced)[cols]
}


consortium <- "MODEL-AD"
study_name <- "UCI_Trem2_Cuprizone"
grant <- "U54AG054349"
version <- "2023-01-17"
# Synapse folders
study <- "syn50670633"
data <- "syn50900314"
staging <- "syn50670639"
docs <- "syn50670643"
metadata <- "syn50670641"
# Synapse tables
fileview <- "syn50908349"
# Metadata files
manifest1 <- "syn50876849"
manifest2 <- "syn50996286"
individual <- "syn50876848"
biospecimen <- "syn50876847"
assay1 <- "syn50876846" # long-read RNAseq
assay2 <- "syn50996285" # bulk RNAseq
assay3 <- ""
 
study_version <-
  file.path(getwd(), "data-curation", consortium, paste0(version, "-", study_name))
tmp <- file.path(study_version, "tmp")

ind <- synGet(individual, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_csv(col_types = "c")
bio <- synGet(biospecimen, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_csv()
as1 <- synGet(assay1, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_csv()
as2 <- synGet(assay2, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_csv()

mn1 <- synGet(manifest1, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_tsv()
mn2 <- synGet(manifest2, downloadLocation = tmp, ifcollision="overwrite.local")$path %>% read_tsv()
 
# Create fileview
project <- Project("MODEL-AD-Annotations") %>% synStore()
keys <- c(
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "modelSystemType", columnType = "STRING"),
  Column(name = "individualIdSource", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "climbID", columnType = "STRING"),
  Column(name = "microchipID", columnType = "STRING"),
  Column(name = "birthID", columnType = "STRING"),
  Column(name = "matingID", columnType = "STRING"),
  Column(name = "materialOrigin", columnType = "STRING"),
  Column(name = "sex", columnType = "STRING"),
  Column(name = "species", columnType = "STRING"),
  Column(name = "generation", columnType = "STRING"),
  Column(name = "dateBirth", columnType = "STRING"),
  Column(name = "ageDeath", columnType = "INTEGER"),
  Column(name = "ageDeathUnits", columnType = "STRING"),
  Column(name = "brainWeight", columnType = "STRING"),
  Column(name = "rodentWeight", columnType = "STRING"),
  Column(name = "rodentDiet", columnType = "STRING"),
  Column(name = "bedding", columnType = "STRING"),
  Column(name = "room", columnType = "STRING"),
  Column(name = "waterpH", columnType = "STRING"),
  Column(name = "treatmentDose", columnType = "STRING"),
  Column(name = "treatmentType", columnType = "STRING"),
  Column(name = "stockNumber", columnType = "STRING"),
  Column(name = "genotype", columnType = "STRING"),
  Column(name = "genotypeBackground", columnType = "STRING"),
  Column(name = "individualCommonGenotype", columnType = "STRING"),
  Column(name = "modelSystemName", columnType = "STRING"),
  Column(name = "officialName", columnType = "STRING"),
  Column(name = "specimenIdSource", columnType = "STRING"),
  Column(name = "organ", columnType = "STRING"),
  Column(name = "tissue", columnType = "STRING"),
  Column(name = "BrodmannArea", columnType = "STRING"),
  Column(name = "sampleStatus", columnType = "STRING"),
  Column(name = "tissueWeight", columnType = "DOUBLE"),
  Column(name = "tissueVolume", columnType = "STRING"),
  Column(name = "nucleicAcidSource", columnType = "STRING"),
  Column(name = "cellType", columnType = "STRING"),
  Column(name = "fastingState", columnType = "STRING"),
  Column(name = "isPostMortem", columnType = "BOOLEAN"),
  Column(name = "samplingAge", columnType = "DOUBLE"),
  Column(name = "samplingAgeUnits", columnType = "STRING"),
  Column(name = "visitNumber", columnType = "INTEGER"),
  Column(name = "libraryID", columnType = "STRING"),
  Column(name = "platform", columnType = "STRING"),
  Column(name = "RIN", columnType = "STRING"),
  Column(name = "referenceSet", columnType = "STRING"),
  Column(name = "rnaBatch", columnType = "STRING"),
  Column(name = "libraryBatch", columnType = "STRING"),
  Column(name = "sequencingBatch", columnType = "STRING"),
  Column(name = "libraryPrep", columnType = "STRING"),
  Column(name = "libraryPreparationMethod", columnType = "STRING"),
  Column(name = "libraryVersion", columnType = "STRING"),
  Column(name = "isStranded", columnType = "BOOLEAN"),
  Column(name = "readStrandOrigin", columnType = "STRING"),
  Column(name = "readLength", columnType = "STRING"),
  Column(name = "runType", columnType = "STRING"),
  Column(name = "totalReads", columnType = "STRING"),
  Column(name = "validBarcodeReads", columnType = "STRING"),
  Column(name = "DV200", columnType = "STRING")
)

schema <-
  EntityViewSchema(
    name = "UCI_Trem2_Cuprizone",
    parent = project$properties$id,
    scopes = study,
    includeEntityTypes = c(EntityViewType$FILE),
    addDefaultViewColumns = TRUE,
    addAnnotationColumns = FALSE,
    columns = keys,
    ignoredAnnotationColumnNames = list("individualID")
  ) %>% synStore()
# Pull existing annotations from Synapse
notes <- 
  synTableQuery(paste("SELECT * FROM", schema$properties$id))$asDataFrame() %>% 
  as_tibble()
# Reduce annotations 
notes <- notes %>% select(1:5,23:28)
notes <- notes %>% mutate(individualID = gsub("^NA", "", individualID))
notes <- notes %>% mutate(specimenID = gsub("^NA", "", specimenID))
# notes <- notes %>% mutate(individualID = as.character(individualID)) 
# notes <- notes %>% mutate(individualID = str_remove(individualID, ".0$"))

ind <- ind %>% mutate(individualID = as.character(individualID))
bio <- bio %>% mutate(individualID = as.character(individualID))
as1 <- as1 %>% mutate(libraryID = as.character(libraryID))
as2 <- as1 %>% mutate(libraryID = as.character(libraryID))

joined <- notes %>% 
  left_join(., ind, by = "individualID") %>% 
  left_join(., bio, by = c("individualID","specimenID")) %>% 
  left_join(., as2, by = c("specimenID", "assay"))


joined <- joined %>% 
  mutate(individualCommonGenotype = str_replace_all(individualCommonGenotype, "Trem2-", "Trem2"))

joined$grant <- grant
joined$study <- study_name
joined$consortium <- consortium

# File formats
joined <-
  joined %>%
  mutate(
    fileFormat = case_when(
      str_detect(name, ".fastq$|fastq.gz") ~ "fastq",
      str_detect(name, ".bam$") ~ "bam",
      str_detect(name, "talon") ~ "talon",
      str_detect(name, ".cram$") ~ "cram",
      str_detect(name, ".csv$") ~ "csv",
      str_detect(name, ".txt$") ~ "txt",
      str_detect(name, ".doc$|docx$") ~ "doc",
      TRUE ~ as.character(NA)
    )
  )


# Resource type
joined <-
  joined %>%
  mutate(
    resourceType = case_when(
      str_detect(name, "Trem2") ~ "metadata",
      str_detect(name, "method") ~ "metadata",
      str_detect(name, "assay") ~ "metadata",
      str_detect(name, ".fastq") ~ "experimentalData",
      str_detect(name, ".bam") ~ "experimentalData",
      str_detect(name, "talon") ~ "experimentalData",
      TRUE ~ as.character(NA)
    )
  )

# Data Type
joined <-
  joined %>%
  mutate(
    dataType = case_when(
      str_detect(name, ".fastq") ~ "geneExpression",
      str_detect(name, ".bam") ~ "geneExpression",
      TRUE ~ as.character(NA)
    )
  )

# Annotate files
joined <-
  joined %>%
  mutate(metadataType = case_when(
    str_detect(name, "individual") ~ "individual",
    str_detect(name, "biospecimen") ~ "biospecimen",
    str_detect(name, "assay") ~ "assay",
    str_detect(name, "manifest") ~ "manifest",
    str_detect(name, "methods") ~ "protocol",
    str_detect(name, "U54AG054349_UCI") ~ "protocol",
    TRUE ~ as.character(NA)))

notes_to_push <- joined %>% select(1:65, 79:82)
synStore(Table(schema$properties$id, notes_to_push))
 
# Join metadata tables
# notes <- coalesce_join(notes, ind, by = "individualID")
# notes <- coalesce_join(notes, bio, by = "specimenID", multiple = NULL, na_matches = "never")
# Remove empty rows
# notes <- notes %>% filter(!is.na(ROW_ID))


# notes$individualID %>% str_replace("NA", na())
# notes$dataType                 <- NA
# notes$assay <- NA
# notes$fileFormat <- NA
# notes$isModelSystem <- NA
# notes$modelSystemType <- NA
# notes$individualIdSource <- NA
# notes$metadataType <- NA
# notes$resourceType <- NA
# notes$climbID <- NA
# notes$microchipID              <- NA
# notes$birthID                  <- NA
# notes$matingID                 <- NA
# notes$materialOrigin           <- NA
# notes$sex                     <- NA
# notes$species                  <- NA
# notes$generation               <- NA
# notes$dateBirth                <- NA
# notes$ageDeath                 <- NA
# notes$ageDeathUnits           <- NA
# notes$brainWeight              <- NA
# notes$rodentWeight             <- NA
# notes$rodentDiet               <- NA
# notes$bedding                  <- NA
# notes$room                    <- NA
# notes$waterpH                  <- NA
# notes$treatmentDose           <- NA
# notes$treatmentType            <- NA
# notes$stockNumber              <- NA
# notes$genotype                <- NA
# notes$genotypeBackground       <- NA
# notes$individualCommonGenotype <- NA
# notes$modelSystemName         <- NA
# notes$officialName             <- NA
# notes$specimenIdSource        <- NA
# notes$organ                    <- NA
# notes$tissue                   <- NA
# notes$BrodmannArea             <- NA
# notes$sampleStatus             <- NA
# notes$tissueWeight            <- NA
# notes$tissueVolume             <- NA
# notes$nucleicAcidSource        <- NA
# notes$cellType                 <- NA
# notes$fastingState             <- NA
# notes$isPostMortem            <- NA
# notes$samplingAge              <- NA
# notes$samplingAgeUnits         <- NA
# notes$visitNumber <- NA




# Move files
# files_ctrlc57 <- 
  
# files2move <- joined %>% 
#   filter(str_detect(name, "TREM2em2Adiuj_TREM2KO_cpz")) %>%
#   select(id)  %>% 
#   as.list() 
# furrr::future_walk(files2move$id, ~ synMove(.x, "syn51078327"))


# files_bulkRNAseq <- joined %>%
#   filter(str_detect(name, "brain_M")) %>% 
#   filter(fileFormat == "fastq") %>% 
#   select(id) %>%
#   as.list()
# furrr::future_walk(files_bulkRNAseq$id, ~ synMove(.x, "syn51033243"))
#
# files_bam <- notes %>%
#   filter(fileFormat == "bam") %>%
#   select(id) %>%
#   as.list()
# furrr::future_walk(files_bam$id, ~ synMove(.x, "syn50921880"))
#
# files_fastq <- notes %>%
#   filter(fileFormat == "fastq") %>%
#   select(id) %>%
#   as.list()
# furrr::future_walk(files_fastq$id, ~ synMove(.x, "syn50921883"))
#
# files_talon <- notes %>%
#   filter(fileFormat == "talon") %>%
#   select(id) %>%
#   as.list()
# furrr::future_walk(files_talon$id, ~ synMove(.x, "syn50921886"))

