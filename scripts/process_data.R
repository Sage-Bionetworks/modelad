# process_data.R

library(dplyr)
library(readxl)
library(readr)

copy_content_to_template <- function(template_path, submitted_path, output_path) {
  template <- read_excel(template_path) # or read_csv since conversion
  submitted <- read_csv(submitted_path)

  common_cols <- intersect(names(template), names(submitted))
  combined_data <- template %>%
    select(any_of(common_cols)) %>%
    bind_rows(submitted %>%
                select(any_of(common_cols))) %>%
    distinct()

  write_csv(combined_data, output_path)
  message("Content copied to template and saved to: ", output_path)
}
