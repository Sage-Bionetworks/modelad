library(synapser)
library(synapserutils)
library(tidyverse)

synLogin()
dev# browseVignettes(package="synapser")

setwd('/Users/ryaxley/Work/Data/2021-09-16-Jax.IU.Pitt_Verubecestat_5XFAD')
path <- 'files/'

# Latest Verubecestat metadata
metadata_id <- 'syn23628037'
behavioral_id <- 'syn23628042'
immunoassay_id <- 'syn26129018'

synapserutils::syncFromSynapse(metadata_id, path = path)
synapserutils::syncFromSynapse(behavioral_id, path = path)
synapserutils::syncFromSynapse(immunoassay_id, path = path)

# read metadata files
md_individual <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_individual_metadata.csv"))
md_biospecimen <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_biospecimen.csv"))
md_assay <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_assay_immunoassay.csv"))

# read behav data files
behav1 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD rotarod.csv"))
behav2 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_Frailty.csv"))
behav3 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_OpenField.csv"))
# behav3 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_OpenField-TEST.csv"))
behav4 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_spontalt.csv")) 

# read immunoassay data files
immun1 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_Ab_molecular_data_model-ad_insoluble.csv"))
immun2 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_Ab_molecular_data_model-ad_plasma.csv"))
immun3 <- read_csv(paste0(path,"Jax.IU.Pitt_Verubecestat_5XFAD_Ab_molecular_data_model-ad_soluble.csv"))

glimpse(behav1)
glimpse(behav2)
glimpse(behav3)
glimpse(behav4)
summary()

# QC - Are all individualIDs in the  data present in the metadata files?

# Do the individualIDs in the behavioral data files exist in the individual metadata?
n_distinct(behav1$IndividualID)/length(behav1$IndividualID)
n_distinct(behav2$individualID)/length(behav2$individualID)
n_distinct(behav3$IndividualID)/length(behav3$IndividualID)
n_distinct(behav4$IndividualID)/length(behav4$IndividualID)

# Are all IndividualIDs in behavioral data in the metadata files. 
# Should all be TRUE or need revised metadata file with all individuals' info.
all(unique(behav1$IndividualID) %in% md_individual$individualID)
all(unique(behav2$individualID) %in% md_individual$individualID)
all(unique(behav3$IndividualID) %in% md_individual$individualID) # No, there is an "NA" value
unique(behav3$IndividualID[unique(behav3$IndividualID) %in% md_individual$individualID])
all(unique(behav4$IndividualID) %in% md_individual$individualID)

n_distinct(md_individual$individualID)/length(md_individual$individualID)
n_distinct(md_biospecimen$specimenID)/length(md_biospecimen$specimenID)


# Are all of the individuals listed in the individual metadata file present in 
# the data files? No, but that is OK. Those individuals may be present in other 
# data files.
sort(md_individual$individualID) %in% behav1$IndividualID
sort(md_individual$individualID) %in% behav2$individualID # case change
sort(md_individual$individualID) %in% behav3$IndividualID
sort(md_individual$individualID) %in% behav4$IndividualID

sort(md_individual$individualID) %in% immun1$individualID
sort(md_individual$individualID) %in% immun2$individualID
sort(md_individual$individualID) %in% immun3$individualID


# What is the next question to ask here????

# Observations:

# Many individuals in metadata file are NOT present in the behavioral OR 
# immunoassay data files. 165 individuals exist, and 158 do NOT
# behav1: Missing dateDeath for some subjects
# behav3: Problem import CSV in R. Resaved in VSCode and it imported fine. Tested again. Test exported file.
# behav2: "individualID" rather than "IndividualID"
# behav3: "NA" value

md_individual$individualID[sort(md_individual$individualID) %in% immun3$individualID]

 
# but the biospecimen file also contains specimens from different assays
# all(bio_meta$specimenID %in% _meta$specimenID)
