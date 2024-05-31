# convert_files.R

library(readxl)
library(readr)
library(stringr)

convert_xlsx_to_csv <- function(input_path) {
  output_path <- str_replace(input_path, "\\.xlsx?$", ".csv")
  data <- read_excel(input_path)
  write_csv(data, output_path)
  message("Converted ", input_path, " to ", output_path)
}

convert_if_not_exists <- function(input_path) {
  output_path <- str_replace(input_path, "\\.xlsx?$", ".csv")
  if (!file.exists(output_path)) {
    convert_xlsx_to_csv(input_path)
  } else {
    message("Output file already exists: ", output_path)
  }
}
