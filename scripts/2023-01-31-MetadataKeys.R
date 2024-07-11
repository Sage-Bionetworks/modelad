library(tidyverse)
library(synapser)
library(synapserutils)
library(lubridate)
synLogin()

# Jax.IU.Pitt_5XFAD - syn21983020
syn22103212 <- synGet(entity='syn22103212' )$path %>% read_csv()
 
# Jax.IU.Pitt_APOE4.Trem2.R47H - syn17095980
syn18345335 <- synGet(entity='syn18345335' )$path %>% read_csv()

# Jax.IU.Pitt_StrainValidation - syn21595255
syn22107822 <- synGet(entity='syn22107822' )$path %>% read_csv() 

# Jax.IU.Pitt_hTau_Trem2 - syn18693211
syn22161041 <- synGet(entity='syn22161041' )$path %>% read_csv() 

# MODEL-AD_JAX_GWAS_Gene_Survey - syn15811463
syn22107822 <- synGet(entity='syn22107822' )$path %>% read_csv() 

# UCI_hAbeta_KI - syn18634479
syn18880212 <- synGet(entity='syn18880212' )$path %>% read_csv() 

keys <- c("datebirth", "datedeath", "genotype", "modelcommon")
syn22103212 %>% select(matches(keys))
syn18345335 %>% select(matches(keys))
syn22107822 %>% select(matches(keys))
syn22161041 %>% select(matches(keys))
syn22107822 %>% select(matches(keys))
syn18880212 %>% select(matches(keys))

syn22103212$dateDeath %>% mdy()
syn22103212$dateBirth %>% mdy()