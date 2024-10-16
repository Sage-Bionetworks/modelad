library(synapser)
library(tidyverse)

synLogin()

# LTP data from 5xFAD
# file1b <- 'syn21292310'
# file2b <- 'syn21292311'
# file3b <- 'syn21292312'
# 
# synGet(file1b, downloadLocation = "files/")
# synGet(file2b, downloadLocation = "files/")
# synGet(file3b, downloadLocation = "files/")

# Latest LTP data in Staging/Electrophysiology/Electrophysiology (LTP)
file1 <- 'syn26192378'
file2 <- 'syn26192379'
file3 <- 'syn26192380'

synGet(file1, downloadLocation = "files/")
synGet(file2, downloadLocation = "files/")
synGet(file3, downloadLocation = "files/")

# Metadata files
meta_rna <- 'syn23532197'
meta_bio <- 'syn23532198'
meta_ind <- 'syn23532199'
meta_scrna <- 'syn25921758'

synGet(meta_rna, downloadLocation = "files/")
synGet(meta_bio, downloadLocation = "files/")
synGet(meta_ind, downloadLocation = "files/")
synGet(meta_scrna, downloadLocation = "files/")

# read metadata files
ind_meta <- read_csv("files/UCI_3xTg-AD_individual_metadata.csv")
bio_meta <- read_csv("files/UCI_3xtg_AD_biospecimen_metadata.csv")
rna_meta <- read_csv("files/UCI_3xTg-AD_assay_rnaSeq_metadata.csv")

# read LTP data files
ltp1 <-  read_csv("files/3xTgAD_UCI_LTPIOCurve.csv")
ltp2 <-  read_csv("files/3xTgAD_UCI_LTPPPF.csv")
ltp3 <-  read_csv("files/3xTgAD_UCI_LTPSlopeExp.csv")

# QC - Are all individualIDs in the LTP data present in the metadata files?

# are all the column headers from the ltp matrix (except the first "gene_id" column) in the assay metadata?
all(colnames(counts[-1]) %in% rna_meta$specimenID)

# are all IndividualIDs
unique(ltp1$IndividualID) %in% ind_meta$individualID
unique(ltp2$IndividualID) %in% ind_meta$individualID
unique(ltp3$IndividualID) %in% ind_meta$individualID

# all specimens from the LTP data file should be in the biospecimen file
n_distinct(ltp1$SpecimenID)
n_distinct(ltp2$SpecimenID)
n_distinct(ltp3$SpecimenID)

all(ltp1$SpecimenID %in% bio_meta$specimenID)
all(ltp2$SpecimenID %in% bio_meta$specimenID)
all(ltp3$SpecimenID %in% bio_meta$specimenID)

# but the biospecimen file also contains specimens from different assays
all(bio_meta$specimenID %in% _meta$specimenID)



# From Abby
# make sure the specimenIDs in the LTP data file are all in the updated biospecimen metadata file
# make sure rows in the biospecimen file have senseible values for tissue, assay, etc.
# for new indivudals, individualIDs should be  the individual metadata file



