# Load required libraries
library(tidyverse)
library(synapser)
library(synapserutils)
library(stringr)
library(docxtractr)
library(readxl)



# scripts/main_script.R

# Source the script containing the function
source("scripts/convert_xlsx_to_csv.R")

# Example usage of the function
input_path <- "path/to/your/input_file.xlsx"
output_path <- "path/to/your/output_file.csv"
convert_xlsx_to_csv(input_path, output_path)




# Function to download files from Synapse without overwriting existing files
download_synapse_files <- function(folder_id, study_name, base_path = "modelad/data") {
  download_path <- file.path(base_path, study_name)
  if (!dir.exists(download_path)) {
    dir.create(download_path, recursive = TRUE)
  }

  existing_files <- list.files(download_path, recursive = TRUE)

  tryCatch({
    synapserutils::syncFromSynapse(folder_id, path = download_path, ifcollision = "keep.local")
    new_files <- setdiff(list.files(download_path, recursive = TRUE), existing_files)
    if (length(new_files) == 0) {
      message("No new files were downloaded from folder ID: ", folder_id)
    } else {
      message("Files downloaded successfully from folder ID: ", folder_id, " to ", download_path)
      message("New files: ", paste(new_files, collapse = ", "))
    }
  }, error = function(e) {
    stop("Failed to download files from Synapse: ", e$message)
  })
}

# Function to copy content from submitted files to templates
copy_content_to_template <- function(template_path, submitted_path, output_path) {
  template <- read_excel(template_path)
  submitted <- read_csv(submitted_path)

  # Match columns by name and copy content using dplyr
  common_cols <- intersect(names(template), names(submitted))
  template <- template %>%
    select(any_of(common_cols)) %>%
    bind_rows(submitted %>%
                select(any_of(common_cols))) %>%
    distinct()

  # Write the output file
  write_csv(template, output_path)
  message("Content copied to template and saved to: ", output_path)
}

# Function to clean up formatting tags
clean_formatting <- function(markdown_content) {
  # Define a pattern to match the formatting tags like <em1Aduci> and <em1*>
  pattern <- "<em1[^>]*>"

  # Replace the pattern with an empty string to remove it
  clean_content <- str_replace_all(markdown_content, pattern, "")

  # Additional cleaning for other potential HTML tags or specific formatting
  clean_content <- str_replace_all(clean_content, "<em>|</em>", "")

  return(clean_content)
}

# Function to convert a .docx file to Markdown, clean formatting, and update a wiki
convert_and_update_wiki <- function(file_name, file_mappings, dry_run = TRUE) {
  # Get the project ID for the wiki from the mappings
  wiki_project <- file_mappings[[file_name]]

  # Construct the document path
  doc_path <- file.path("modelad/data/docs", file_name)

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

  if (dry_run) {
    message("Dry run: Wiki update prepared for file: ", file_name)
    return()
  }

  # Check if the wiki already exists
  wiki_object <- tryCatch(synGetWiki(wiki_project), error = function(e) NULL)
  existing_content <- if (!is.null(wiki_object)) wiki_object$markdown else ""

  # Update the wiki only if it's empty
  if (existing_content == "") {
    wiki <- Wiki(owner = wiki_project, markdownFile = output_file)
    synStore(wiki)
    message("Wiki updated for project: ", wiki_project)
  } else {
    message("Wiki already has content. Skipping update for project: ", wiki_project)
  }
}

# Main function to execute the script
main <- function() {
  # Synapse Project info
  ticket <- "https://sagebionetworks.jira.com/browse/ADM-2687"
  study <- "UCI_CCLines"
  program <- "MODEL-AD"
  grant <- "U54AG054349"

  # Synapse folder IDs
  study_id <- "syn51713891"
  staging_id <- "syn51713893"
  docs_id <- "syn51713896"
  metadata_id <- "syn51713897"
  rnaseq_id <- "syn51713902"
  electro_id <- "syn58841752"

  # Log in to Synapse
  synLogin()

  # Download metadata files without overwriting existing files
  download_synapse_files(metadata_id, study)

  # Define paths to metadata templates
  base_path <- file.path("modelad/data", study)
  assay_template_path <- file.path(base_path, "assay_rnaSeq_metadata_template.xlsx")
  biospecimen_template_path <- file.path(base_path, "biospecimen_metadata_template.xlsx")
  individual_template_path <- file.path(base_path, "individual_animal_metadata_template.xlsx")

  # Define paths to user-submitted files
  submitted_rnaseq_path <- file.path(base_path, "UCI_CollaborativeCross_RNAseq.csv")
  submitted_biospecimen_path <- file.path(base_path, "UCI_CollaborativeCross_biospecimen_metadata.csv")
  submitted_individual_path <- file.path(base_path, "UCI_CollaborativeCross_IndividualID.csv")

  # Define output paths and check if they need to be created
  output_rnaseq_path <- file.path(base_path, "UCI_CCLines_assay_rnaSeq_metadata.csv")
  output_biospecimen_path <- file.path(base_path, "UCI_CCLines_biospecimen_metadata.csv")
  output_individual_path <- file.path(base_path, "UCI_CCLines_individual_animal_metadata.csv")

  # Copy content from submitted files to templates and save as new files
  if (!file.exists(output_rnaseq_path)) {
    copy_content_to_template(assay_template_path, submitted_rnaseq_path, output_rnaseq_path)
  } else {
    message("Output file already exists: ", output_rnaseq_path)
  }

  if (!file.exists(output_biospecimen_path)) {
    copy_content_to_template(biospecimen_template_path, submitted_biospecimen_path, output_biospecimen_path)
  } else {
    message("Output file already exists: ", output_biospecimen_path)
  }

  if (!file.exists(output_individual_path)) {
    copy_content_to_template(individual_template_path, submitted_individual_path, output_individual_path)
  } else {
    message("Output file already exists: ", output_individual_path)
  }

  # File mappings: document names to folder IDs
  file_mappings <- list(
    "U54AG054349_UCI CCnF1.5xFAD.docx" = study_id,
    "UCI_ABCA7_bulk RNA seq.docx" = rnaseq_id,
    "UCI_CollaborativeCross_MSD.docx" = electro_id
  )

  # Pull study and assay descriptions from Synapse
  download_synapse_files(docs_id, "docs")

  # Iterate through the file mappings and update wikis (dry run by default)
  for (file_name in names(file_mappings)) {
    print(file_name)
    convert_and_update_wiki(file_name, file_mappings, dry_run = TRUE)
  }

  # Pull additional data from Synapse
  download_synapse_files("syn58847245", study)

  # Read and view the manifest file
  manifest_path <- file.path(base_path, "UCI_CC_manifest_081523.txt")
  manifest <- read_tsv(manifest_path)
  print(manifest)

  # Filter and view manifest for files not in CSV format
  manifest %>% filter(fileFormat != "csv") %>% print()
}

# Execute the main function
main()
