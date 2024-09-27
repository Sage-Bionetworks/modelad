# data_utils.R: Functions for data manipulation and curation tasks

library(dplyr)
library(janitor)
library(readr)
library(readxl)
library(yaml)
library(tidyverse)
library(stringr)

# Function: Copy content from a submitted file to a template
# This function reads data from an Excel template and a CSV file,
# merges them on common columns, and saves the result as a new CSV.
copy_content_to_template <- function(template_path, submitted_path, output_path) {
    tryCatch(
        {
            template <- read_excel(template_path)
            submitted <- read_csv(submitted_path)

            common_cols <- intersect(names(template), names(submitted))
            combined_data <- template %>%
                select(any_of(common_cols)) %>%
                bind_rows(submitted %>% select(any_of(common_cols))) %>%
                distinct()

            write_csv(combined_data, output_path)
            message("Content copied to template and saved to: ", output_path)
        },
        error = function(e) {
            message("Error copying content to template: ", e$message)
        }
    )
}

# Function: Process metadata by joining and cleaning data from multiple sources
# This function loads individual, biospecimen, and assay metadata,
# performs left joins to combine them, and removes empty rows and columns.
process_metadata <- function(individual_path, biospecimen_path, assay_path, output_path) {
    tryCatch(
        {
            load(individual_path)
            load(biospecimen_path)
            load(assay_path)

            combined_metadata <- individual_metadata %>%
                left_join(biospecimen_metadata, by = "individualID") %>%
                left_join(assay_metadata, by = c("assay", "specimenID"))

            clean_metadata <- combined_metadata %>%
                select(where(~ !all(is.na(.)))) %>%
                filter(rowSums(is.na(.)) != ncol(.))

            save(clean_metadata, file = output_path)
            message("Cleaned metadata saved to: ", output_path)
        },
        error = function(e) {
            message("Error processing metadata: ", e$message)
        }
    )
}

# Function: Generate a configuration template in YAML format
# Creates a basic template with placeholders for study details.
generate_config_template <- function(template_path) {
    template <- list(
        studyID = "example_study_id",
        studyName = "Example Study Name",
        program = "Example Program"
    )

    yaml::write_yaml(template, template_path)
    print(sprintf("Configuration template saved to %s", template_path))
}

# Function: Add a new study to a study configuration CSV
# This function reads an existing study configuration CSV,
# adds a new study from a YAML config file, and updates the CSV.
add_synapse_study <- function(current_study, config_path, csv_path) {
    study_df <- read_csv(csv_path) %>% as_tibble()
    study_config <- yaml::read_yaml(config_path)

    new_record <- tibble(
        Attribute = study_config$studyID,
        Description = study_config$studyName,
        `Valid Values` = NA,
        DependsOn = NA,
        Properties = NA,
        Required = NA,
        Parent = "study",
        `DependsOn Component` = NA,
        Source = study_config$source,
        `Validation Rules` = NA,
        columnType = "string",
        module = study_config$module
    )

    if (!(new_record$Attribute %in% study_df$Attribute)) {
        updated_study_df <- bind_rows(study_df, new_record)
        print(sprintf("Added Study %s", new_record$Attribute))
    } else {
        stop(sprintf("Study ID %s already exists in the study CSV.", new_record$Attribute))
    }

    # Normalize and sort records
    updated_study_df <- updated_study_df %>%
        mutate(Attribute_normalized = str_replace_all(str_to_lower(Attribute), "[^a-z0-9]", "")) %>%
        mutate(order = ifelse(Attribute == "study", 1, 2)) %>%
        arrange(order, Attribute_normalized) %>%
        select(-order, -Attribute_normalized)

    return(updated_study_df)
}

# Example usage
# generate_config_template("/path/to/save/template.yaml")
# add_synapse_study("Jax.IU.Pitt_LOAD2.PrimaryScreen", "modelad/data/study_config.yaml", "data-models/modules/ADKP/study.csv")
