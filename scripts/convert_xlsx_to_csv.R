# Load required libraries
# scripts/convert_xlsx_to_csv.R

# Load required libraries
library(readxl)
library(readr)

# Function to convert xlsx to csv
convert_xlsx_to_csv <- function(input_path, output_path) {
  # Read the Excel file
  data <- read_excel(input_path)

  # Write the data to a CSV file
  write_csv(data, output_path)

  message("Converted ", input_path, " to ", output_path)
}

