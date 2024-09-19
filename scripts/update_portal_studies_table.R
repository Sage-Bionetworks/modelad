library(tidyverse)
library(tidyverse)
library(synapser)
library(yaml)
library(dplyr)
library(stringr)

# Synapse login
synLogin()


# Retrieve the schema of the Synapse table
table_schema <- synGetTableColumns(table_id)

# Convert the table schema (Python generator-like object) to a list
table_schema_list <- as.list(table_schema)

# Extract column information from the schema and store it in a data frame
table_schema_df <- map_dfr(table_schema_list, function(col) {
  tibble(
    ColumnName = col$name,
    ColumnType = col$columnType,
    MaxSize = if (!is.null(col$maximumSize)) col$maximumSize else NA,  # Some columns might not have a MaxSize
    EnumValues = if (!is.null(col$enumValues)) paste(col$enumValues, collapse = ", ") else NA  # For columns with enumerated values
  )
})

# Print out the schema of the Synapse table
print(table_schema_df)

# Save the schema as a CSV for reference (optional)
write_csv(table_schema_df, "modelad/synapse_table_schema.csv")








# Load study configuration from study_config.yml
study_config <- yaml::read_yaml('modelad/studies/Jax.IU.Pitt_LOAD2/study_config.yml')

# Extract study details for filtering or updating the table
study_name <- study_config$study$name
program <- "MODEL-AD"  # Assuming the program is MODEL-AD based on your context

# Query to retrieve all rows from the table
query_all <- sprintf("SELECT * FROM %s", table_id)
query_result_all <- synTableQuery(query_all)

# Load the table data into a data frame
table_data <- query_result_all$filepath %>%
  read_csv()

# Filter the table data to find rows related to the study
filtered_data <- table_data %>%
  filter(str_detect(Program, program) & Study_Type == 'Individual')

# Print and view the filtered data
filtered_data %>% view()

# Check if the study already exists in the table
if (any(filtered_data$Study_Name == study_name)) {
  cat("Study already exists in the table. Proceeding to update the row if necessary.\n")

  # Update the existing row (if any new information needs to be updated)
  updated_data <- table_data %>%
    mutate(Study_Name = ifelse(Study_Name == study_name, study_name, Study_Name),
           Program = ifelse(Program == program, Program, program))
} else {
  cat("Study not found in the table. Adding a new row for the study.\n")

  # Create a new row with study information
  new_row <- tibble(
    Study_Name = study_name,
    Program = program,
    # Add additional fields from the study_config if necessary
    Study_Type = 'Individual'
    # Add more columns as per the table structure
  )

  # Append the new row to the table data
  updated_data <- bind_rows(table_data, new_row)
}

# Write the updated table back to Synapse
# Create a temporary file to store the updated CSV
temp_file <- tempfile(fileext = ".csv")
write_csv(updated_data, temp_file)

# Store the updated table back to Synapse
synStore(Table(table_id, temp_file))

cat("Updated table saved back to Synapse.\n")
