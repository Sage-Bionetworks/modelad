library(tidyverse)
library(synapser)
library(synapserutils)

# Goals: UCI uploaded a revised data file. I need to download the file, verify the changes when compared to the previous version, and upload the file as a new version.

synLogin(silent = TRUE)
setwd("/Users/ryaxley/Documents/GitHub/sageCuration/2022-02-21-UCI_5XFAD")

new_entity <- synGet("syn27079262")
old_entity <- synGet("syn22049825")
# 
# # Inspect files manually
# synGet(new_entity, downloadLocation = "temp/new", ifcollision = "overwrite.local")
# synGet(old_entity, downloadLocation = "temp/old", ifcollision = "overwrite.local")
# 
# # Import data
# new <- new_entity$path %>% read_csv() # 5xFAD 4, 8 12 and 18 months_ ThioS-IBA1.csv
# old <- old_entity$path %>% read_csv() # 5xFAD 4, 8 12 and 18 months_ ThioS-IBA1.csv
# spec(new)
# spec(old)
# 
# # Compare data frames
# dplyr::all_equal(new, old)
# janitor::compare_df_cols(new, old)
# diffdf::diffdf(new, old)
# 
# # Do column names match?
# table(colnames(new) %in% colnames(old))
# 
# # Are all individualIDs in new in old?
# table(new$IndividualID %in% old$IndividualID)
# table(old$IndividualID %in% new$IndividualID)
# 
# # Differences between dataframes
# anti_join(new, old) 
# anti_join(old, new)
# 
# # Observations
# # New file - removed values for 570, 570rh, 570rc
# # New file - added values for 567, 567rh, 567rc (Iba1 stain)
# 
# new %>% filter(IndividualID == "570")
# old %>% filter(IndividualID == "570")
# new %>% filter(IndividualID == "567")
# old %>% filter(IndividualID == "567")
# 
# # Upload new file to old entity
# old_entity$path <- new_entity$path
# old_entity$versionComment <- "Revised values"
# updated_file <- synStore(old_entity)
