# Load necessary libraries
library(tidyverse)
library(stringr)
library(yaml)
library(fs)

# Define file paths
current_study <- "Jax.IU.Pitt_LOAD2.PrimaryScreen"
config_path <- str_glue("modelad/data/{current_study}/study_config.yaml")
csv_path <- "data-models/modules/ADKP/study.csv"

# Read CSV and configuration files
study_df <- read_csv(csv_path) %>% as_tibble()
study_config <- yaml::read_yaml(config_path)

# Create a new record from the study configuration
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

# Check if the study ID already exists in the CSV
if (!(new_record$Attribute %in% study_df$Attribute)) {
  # Add the new record to the dataframe
  updated_study_df <- bind_rows(study_df, new_record)
  print(str_glue("Added Study {new_record$Attribute}"))
} else {
  stop(str_glue("Study ID {new_record$Attribute} already exists in the study CSV."))
}

# Normalize the Attribute column ignoring case and special characters
updated_study_df <- updated_study_df %>%
  mutate(Attribute_normalized = str_replace_all(str_to_lower(Attribute), "[^a-z0-9]", ""))

# Add the order column to ensure the 'study' row is first, then sort by normalized Attribute
updated_study_df <- updated_study_df %>%
  mutate(order = ifelse(Attribute == "study", 1, 2)) %>%
  arrange(order, Attribute_normalized) %>%
  select(-order, -Attribute_normalized)

# Compare all values in the Attribute column with all values listed in the Valid Values column
valid_values <- updated_study_df$`Valid Values` %>%
  na.omit() %>%
  unlist() %>%
  strsplit(",") %>%
  unlist() %>%
  trimws()

# Check if the current study is present in the valid values
if (!(current_study %in% valid_values)) {
  print(str_glue("The current study {current_study} is NOT present in the valid values. Appending it now."))

  # Append the current study to the valid values list
  valid_values <- sort(c(valid_values, current_study))

  # Convert back to comma-separated list format
  updated_valid_values <- paste(valid_values, collapse = ", ")

  # Update the Valid Values column in the dataframe
  updated_study_df$`Valid Values`[1] <- updated_valid_values
  print("Updated Valid Values:")
  print(updated_valid_values)
} else {
  print(str_glue("The current study {current_study} is already present in the valid values."))
}

# Replace NA values with appropriate empty values in the dataframe
# updated_study_df <- updated_study_df %>%
#   mutate(across(where(is.character), ~replace_na(., ""))) %>%
#   mutate(across(where(is.numeric), ~replace_na(., 0))) %>%
#   mutate(across(where(is.logical), ~replace_na(., FALSE)))

# Write the updated dataframe to the specified path
write_csv(updated_study_df, csv_path, na = "")
print(str_glue("Updated study dataframe has been written to {csv_path}"))

# Print success message and new record details
print(str_glue("Successfully added the study with ID {new_record$Attribute} to the CSV."))
print(new_record)

# Create git commit message
git_commit_message <- str_glue("Add study: {study_config$studyID}")
print(git_commit_message)
