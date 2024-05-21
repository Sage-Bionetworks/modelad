library(tidyverse)
library(synapser)
library(synapserutils)
library(stringr)
library(officer)
library(docxtractr)
# library(furrr)

synLogin()

# Synapse Project info
study <- "UCI_CollaborativeCrossLines"
ticket <- "https://sagebionetworks.jira.com/browse/ADM-2687"
program <- "MODEL-AD"
grant <- "U54AG054349"

# Synapse folders
study_id <- "syn51713891"
staging_id <- "syn51713893"
rnaseq_id <- "syn51713902"
electro_id <- "syn58841752"
metadata_id <- "syn51713897"
docs_id <- "syn51713896"

file_mappings <- list(
  "U54AG054349_UCI CCnF1.5xFAD.docx" = study_id,
  "UCI_ABCA7_bulk RNA seq.docx" = rnaseq_id,
  "UCI_CollaborativeCross_MSD.docx" = electro_id
)


# Pull study and assay descriptions
docs <- docs_id %>% paste("synapse get -r", .) %>% system()


# Function to create a new wiki
create_new_wiki <- function(wiki_project, wiki_title, markdown_content) {
  wiki <- Wiki(owner = wiki_project,
               title = wiki_title,
               markdown = markdown_content)
  wiki <- synStore(wiki)
}

# Function to convert a .docx file to Markdown and update a wiki
convert_and_update_wiki <-
  function(file_name, file_mappings) {
    # New parameter
    wiki_project <- file_mappings[[file_name]] # Look up the ID

    # --- DOCX to Markdown Conversion ---
    # Construct output file name
    output_file <- paste0(sub(".docx$", ".md", doc_path))

    # Construct and execute pandoc command
    paste0("pandoc -f docx -t markdown_strict --wrap=none '",
           doc_path,
           "' -o '",
           output_file,
           "'") %>% system()

    wiki_object <-
      tryCatch(
        synGetWiki(wiki_project),
        error = function(e)
          NULL
      )

    existing_content <-
      if (!is.null(wiki_object))
        wiki_object$markdown
    else

      # Update wiki only if empty
      if (existing_content == "") {
        wiki <- Wiki(owner = wiki_project,
                     markdownFile = output_file)
        wiki <- synStore(wiki)
      } else {
        print("Wiki already has content. Skipping update.")
      }
  }


# Iterate through the mappings
for (file_name in names(file_mappings)) {
  print(file_name)
  convert_and_update_wiki(file_name, file_mappings)
}



"synapse get -r syn58847245" %>% system()

manifest <- "UCI_CC_manifest_081523.txt" %>% read_tsv() %>% view

manifest %>% filter(fileFormat != "csv") %>% view


