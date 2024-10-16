library(synapser)
library(yaml)
library(dplyr)
library(purrr)
source("modelad/code/curation_utils.R")

synLogin()

# Read configs
study_config <- yaml::read_yaml("~/modelad/projects/Jax.IU.Pitt_5XFAD.yml")
project_config <- yaml::read_yaml("~/modelad/projects/projects.yml")

# Extract Synapse IDs
individual_metadata_id <- study_config$metadata$individual
fileview_id <- "syn63818787"

# Query the file view
notes <- query_to_tibble(fileview_id)

# Get and read specific file as tibble
file <- synGet(individual_metadata_id)
individual <- read_csv(file$path)

individual %>% glimpse()
individual$sex %>% unique()


individual %>% mutate(sex = str_trim(sex))
# Save the cleaned file locally
cleaned_file_path <- file.path("~/modelad/tmp", "cleaned_individual_metadata.csv")
write_csv(individual, cleaned_file_path)
