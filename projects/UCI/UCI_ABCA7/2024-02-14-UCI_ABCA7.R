library(tidyverse)
library(synapser)
library(stringr)
library(furrr)
library(synapserutils)
library(officer)
library(docxtractr)

synLogin()


# Synapse Project info
ticket <- "https://sagebionetworks.jira.com/browse/ADM-2501"
study <- "UCI_ABCA7"
program <- "MODEL-AD"
grant <- "U54AG054349"
# Synapse folders
study_id <- "syn27207345"
staging_id <- "syn27207360"
metadata_id <- "syn27207357"
descriptions_id <- "syn53646565"
rnaseq_id <- "syn53606335"
immuno_id <- "syn53616342"
electro_id <- "syn53616447"


# Pull study and assay descriptions
# files <- synapserutils::syncFromSynapse(descriptions_id)
# synapserutils::syncFromSynapse(entity, path=NULL, ifcollision=overwrite.local, allFiles=NULL, followLink=FALSE)
# permissions error. had to download manually.

# Function to create a new wiki (assumes you have the necessary functions)
create_new_wiki <- function(wiki_project, wiki_title, markdown_content) {
  wiki <- Wiki(owner = wiki_project,
               title = wiki_title,
               markdown = markdown_content)
  wiki <- synStore(wiki)
}

# Function to convert a .docx file to Markdown and update a wiki
convert_and_update_wiki <-
  function(doc_path, wiki_project) {
    # --- DOCX to Markdown Conversion ---
    # Construct output file name
    output_file <- paste0(sub(".docx$", ".md", doc_path))

    # Construct and execute pandoc command
    pandoc_command <-
      paste0("pandoc -f docx -t markdown_strict --wrap=none '",
             doc_path,
             "' -o '",
             output_file,
             "'")
    system(pandoc_command)
    wiki <- Wiki(owner = wiki_project,
                 markdownFile = output_file)
    wiki <- synStore(wiki)
  }

# Call the function
convert_and_update_wiki(file.path("UCI_ABCA7_study description.docx"), study_id)
convert_and_update_wiki(file.path("UCI_ABCA7_IHC.docx"), immuno_id)
convert_and_update_wiki(file.path("UCI_ABCA7_bulk RNA seq.docx"), rnaseq_id)
convert_and_update_wiki(file.path("UCI_ABCA7_MSD.docx"), electro_id)


# Tasks to do

# update Portal - Studies Table for Study Card Details
# https://www.synapse.org/#!Synapse:syn17083367/tables/

# add synapse IDs of folder wikis portal studies table

query <- synTableQuery("SELECT * FROM syn17083367 WHERE Program LIKE '%MODEL-AD%'")
studies <- read.table(query$filepath, sep = ",", header = TRUE)
studies %>% colnames()
studies %>% dim
studies %>% view()
# studies <-
#   add_row(studies,
#           Program = "MODEL-AD",
#           Study = study)



studies %>% filter(Program == program)
# Merge manifests
# man1 <- synGet("syn30859397")$path %>% read_tsv()
# man2 <- synGet("syn53127511")$path %>% read_tsv()
# man3 <- synGet("syn53144808")$path %>% read_tsv()

# man1 <- man1 %>% janitor::remove_empty("cols")
# man2 <- man2 %>% janitor::remove_empty("cols")
# man3 <- man3 %>% janitor::remove_empty("cols")
# merge(man1, man2, by = "") %>% view
# manifest1 %>% view


# File Annotation
minimum_annotation_set <- c(
  Column(name = "resourceType", columnType = "STRING"),
  Column(name = "metadataType", columnType = "STRING"),
  Column(name = "assay", columnType = "STRING"),
  Column(name = "dataType", columnType = "STRING"),
  Column(name = "fileFormat", columnType = "STRING"),
  Column(name = "isMultiSpecimen", columnType = "BOOLEAN"),
  Column(name = "isModelSystem", columnType = "BOOLEAN"),
  Column(name = "grant", columnType = "STRING"),
  Column(name = "consortium", columnType = "STRING"),
  Column(name = "study", columnType = "STRING"),
  Column(name = "individualID", columnType = "STRING"),
  Column(name = "specimenID", columnType = "STRING")
)

# Configure fileview schema
schema <- EntityViewSchema(
  name = study_name,
  parent = fileviews_id,
  scopes = study_id,
  includeEntityTypes = c(EntityViewType$FILE),
  addDefaultViewColumns = TRUE,
  addAnnotationColumns = FALSE,
  columns = minimum_annotation_set
)

# Upload schema
schema <- synStore(schema)
fileview_id <- schema$properties$id
# [fileview](paste0("https://www.synapse.org/#!Synapse:", fileview_id) #no space, no {r}

# query and pull annotations from Synapse and convert to a tibble
query <- paste("SELECT * FROM", fileview_id)
notes <-
  synTableQuery(query)$asDataFrame() %>%
  as_tibble()

# copy pulled notes for reference before pushing changes
df <- notes

# fill in blanks
df <-
  df %>%
  mutate_at("consortium", ~ ifelse(is.na(.) | . == "", program, .)) %>%
  mutate_at("grant", ~ ifelse(is.na(.) | . == "", grant, .)) %>%
  mutate_at("study", ~ ifelse(is.na(.) | . == "", study_name, .))

# File format
df <-
  df %>%
  mutate(fileFormat = case_when(
    is.na(name) | name == "" ~ NA_character_, # Handle empty or NA cells directly
    str_detect(name, "txt$") ~ "txt",
    str_detect(name, "csv$") ~ "csv",
    str_detect(name, "tsv$") ~ "tsv", # Use \\. to escape the dot
    str_detect(name, "vcf$") ~ "vcf",
    str_detect(name, "vcf\\.gz$") ~ "vcf",
    str_detect(name, "cram$") ~ "cram",
    str_detect(name, "fastq$") ~ "fastq",
    str_detect(name, "fq.gz$") ~ "fastq",
    str_detect(name, "doc[x]$") ~ "fastq",
    TRUE ~ NA_character_ # Default to NA
  ))

# Resource type
df <-
  df %>%
  mutate(
    resourceType = case_when(
      str_detect(name, "manifest|metadata|assay") ~ "metadata",
      str_detect(name, "fq|fastq") ~ "experimentalData",
      str_detect(name, "NfL|pathology") ~ "experimentalData",
      str_detect(name, "description") ~ "metadata",
      TRUE ~ as.character(NA)
    )
  )


# Organize files
# Create lists for each distinct assay type
rnaSeq_list <- df %>%
  filter(str_detect(assay, "rnaSeq")) %>%
  select(id, name) %>%
  as.list()

immunofluor_list <- df %>%
  filter(str_detect(name, "pathology")) %>%
  select(id, name) %>%
  as.list()

electrochem_list <- df %>%
  filter(str_detect(name, "NfL|Abeta")) %>%
  select(id, name) %>%
  as.list()

# Move files if needed
# furrr::future_walk(immunofluor_list$id, ~synMove(.x, immunofluor_id))
# furrr::future_walk(electrochem_list$id, ~synMove(.x, electrochem_id))
# furrr::future_walk(rnaSeq_list$id, ~synMove(.x, rnaSeq_id))

# push changes if needed
synStore(Table(fileview, df))
system("ls -la")
system("synapse get -r syn53646565")



# read metadata files
ind <- synGet("syn30859394")$path %>% read_csv()
bio <- synGet("syn30859390")$path %>% read_csv()
rnaSeq <- synGet("syn53127285")$path %>% read_csv()


left_join(ind, bio) %>%
  janitor::remove_empty("cols") %>%
  view()
