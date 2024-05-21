# Load required libraries
library(tidyverse)
library(synapser)
library(synapserutils)
library(stringr)
library(officer)
library(docxtractr)

# Log in to Synapse
synLogin()

# Synapse Project info
study <- "UCI_CollaborativeCrossLines"
ticket <- "https://sagebionetworks.jira.com/browse/ADM-2687"
program <- "MODEL-AD"
grant <- "U54AG054349"

# Synapse folder IDs
study_id <- "syn51713891"
staging_id <- "syn51713893"
rnaseq_id <- "syn51713902"
electro_id <- "syn58841752"
metadata_id <- "syn51713897"
docs_id <- "syn51713896"

# File mappings: document names to folder IDs
file_mappings <- list(
  "U54AG054349_UCI CCnF1.5xFAD.docx" = study_id,
  "UCI_ABCA7_bulk RNA seq.docx" = rnaseq_id,
  "UCI_CollaborativeCross_MSD.docx" = electro_id
)

# Pull study and assay descriptions from Synapse
system(paste("synapse get -r", docs_id))

# Function to create a new wiki
create_new_wiki <- function(wiki_project, wiki_title, markdown_content) {
  wiki <- Wiki(owner = wiki_project,
               title = wiki_title,
               markdown = markdown_content)
  synStore(wiki)
}

# Function to clean up formatting tags
clean_formatting <- function(markdown_content) {
  # Define a pattern to match the formatting tags like <em1Aduci> and <em1*>
  pattern <- "<em1[^>]*>"
  
  # Replace the pattern with an empty string to remove it
  clean_content <- str_replace_all(markdown_content, pattern, "")
  
  # Additional cleaning for other potential HTML tags or specific formatting
  # For example, removing <em> and </em> tags if present
  clean_content <- str_replace_all(clean_content, "<em>|</em>", "")
  
  return(clean_content)
}

# Function to convert a .docx file to Markdown, clean formatting, and update a wiki
convert_and_update_wiki <- function(file_name, file_mappings) {
  # Get the project ID for the wiki from the mappings
  wiki_project <- file_mappings[[file_name]]
  
  # Construct the document path
  doc_path <- file_name
  
  # Construct output file name
  output_file <- sub(".docx$", ".md", doc_path)
  
  # Convert DOCX to Markdown using pandoc
  system(paste("pandoc -f docx -t markdown_strict --wrap=none '", doc_path, "' -o '", output_file, "'"))
  
  # Read the converted Markdown content
  markdown_content <- read_file(output_file)
  
  # Clean the formatting from the content
  cleaned_content <- clean_formatting(markdown_content)
  
  # Write the cleaned content back to the output file
  write_file(cleaned_content, output_file)
  
  # Check if the wiki already exists
  wiki_object <- tryCatch(synGetWiki(wiki_project), error = function(e) NULL)
  existing_content <- if (!is.null(wiki_object)) wiki_object$markdown else ""
  
  # Update the wiki only if it's empty
  if (existing_content == "") {
    wiki <- Wiki(owner = wiki_project, markdownFile = output_file)
    synStore(wiki)
  } else {
    print("Wiki already has content. Skipping update.")
  }
}

# Iterate through the file mappings and update wikis
for (file_name in names(file_mappings)) {
  print(file_name)
  convert_and_update_wiki(file_name, file_mappings)
}

# Pull additional data from Synapse
system("synapse get -r syn58847245")

# Read and view the manifest file
manifest <- read_tsv("UCI_CC_manifest_081523.txt")
view(manifest)

# Filter and view manifest for files not in CSV format
manifest %>% filter(fileFormat != "csv") %>% view()
