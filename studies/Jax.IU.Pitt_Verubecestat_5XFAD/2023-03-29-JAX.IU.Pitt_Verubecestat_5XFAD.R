library(tidyverse)
library(synapser)
synLogin()

consortium <- "MODEL-AD"
grant <- "U54AG054345"
study <- "Jax.IU.Pitt_Verubecestat_5XFAD"
version <- "2023-02-21"

# Synapse folders
study_id <- "syn21863375"
data_id <- "syn26428682"
staging_id <- "syn23628033"
individual_id <- "syn22251788"
biospecimen_id <- "syn51247163"
biospecimen_id_old <- "syn26136407"
assay1_id <- "syn51247176"
proteomics_id <- "syn51247164"

tmp <- file.path(getwd(), "data-curation", consortium, "tmp",
                 paste0(version, "-", study))

proteomics <- synGet(proteomics_id, 
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

ind <- synGet(individual_id, 
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

bio <- synGet(biospecimen_id, 
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()

bio_old <- synGet(biospecimen_id_old, 
              downloadLocation = tmp, 
              version = 2, 
              ifcollision = "overwrite.local")$path %>% read_csv()

as1 <- synGet(assay1_id, 
              downloadLocation = tmp, 
              ifcollision = "overwrite.local")$path %>% read_csv()
              


ind %>% view

# rows in bio that are not in bio_old (i.e. new rows) 
bio %>% anti_join(bio_old, by = "specimenID") %>% view

# column names that are different between bio and bio_old
bio %>% colnames() %>% setdiff(bio_old %>% colnames())
bio_old %>% colnames() %>% setdiff()

# what does setdiff() do?
bio %>% colnames() %>% setdiff(bio_old %>% colnames()) %>% 
  map(~bio %>% select(., .x)) %>% bind_rows() # explain this code to me please 


# rows in bio that are not in bio_old (i.e. new rows)
bio %>% anti_join(bio_old, by = "specimenID") %>% view

# which columns in bio are empty?
bio %>% select_if(~all(is.na(.))) %>% colnames()

# which individualID in bio do not exist in ind?
bio %>% anti_join(ind, by = "individualID") %>% view