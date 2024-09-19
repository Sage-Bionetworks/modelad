## Categorizing:

* Major – This issue makes any related data un-usable for analysis, and/or requires significant effort from the original data contributor to fix  
* Moderate – This issue can be worked around with some effort and related data is probably usable, but the original data contributor still needs to fix it  
* Minor – This issue can be worked around with very little effort (e.g. typos and naming conventions), and I could fix the file in less than 5 minutes by hand or with an R script

**If a study isn’t listed in this doc, that means I haven’t looked at the metadata for it yet.** These issues are just what I’ve found while looking at the studies we are analyzing RNAseq data for.

## Jax.IU.Pitt\_5XFAD

Individual metadata (syn22103212):

* **Major**  
  * "ageDeath" and "ageDeathUnits" columns are missing   
  * Some mice are missing "dateBirth" or "dateDeath" entries  
    * which is a problem when "ageDeath" is also missing because age cannot be calculated for these mice  
  * Individuals 289904014, 289973785, 289973891, 289973901, and 289974000 all have a "dateDeath" that is earlier than "dateBirth"  
* Minor  
  * Some rows have "sex" listed as "female " (with an extra space) instead of "female"

   
 

## Jax.IU.Pitt\_APOE4.Trem2.R47H

RNA seq assay metadata (syn18345333):

* **Major**  
  * Missing all brain RNA seq samples. Seems to include blood only.   
    * RNA seq samples can still be associated to an individual because of the biospecimen metadata, but adding sample info to the assay metadata file is a significant effort for the data contributor.  
  * There are 33 specimen IDs in this file that do not exist in the biospecimen metadata file, so they cannot be tied back to an individual mouse.

Individual metadata (syn18345335):

* **Major**  
  * 47 samples are missing a genotype value  
  * There are 382 unique individual IDs in the biospecimen metadata file that do not exist in the individual metadata file  
    * For brain RNA seq samples specifically, the individual metadata file is missing rows for IDs 20440, 20456, 20810, and 26305

* Minor  
  * There are 922 rows but only 237 unique individual IDs. Rows with the same individual ID seem to be exact duplicates of each other.   
  * Genotypes are labeled inconsistently within the file. For example, "APOE4\_noncarrier" and "APOE4\_noncarrier;TREM2R47H\_noncarrier" are probably the same genotype but have two different labels. Same with "TREM2R47H\_homozygous" and "APOE4\_noncarrier;TREM2R47H\_homozygous".  
  * Genotype names do not conform to the MODEL-AD approved values list

General problems for RNA seq (syn17095986 and syn22101097): 

* **Major**  
  * There are fastq files for 1 specimen that doesn't exist in the individual or biospecimen metadata files (but exists in the RNA seq assay metadata):  
    * 251rh  
    * We can't use them for analysis without knowing what mouse they came from

   
 

## UCI\_3xTg-AD

Individual metadata (syn23532199):

* Minor  
  * Column names are capitalized inconsistently (e.g. "StockNumber", where most other studies use "stockNumber")  
  * Genotype "3XTg-AD\_noncarrier" should be "3xTg-AD\_noncarrier" to conform to the MODEL-AD approved values and be consistent with the carrier genotype name  
  * genotypeBackground "B6129" doesn't match anything on the MODEL-AD approved values list

Biospecimen metadata (syn23532198):

* Minor  
  * There are 15 empty columns at the end

   
 

## UCI\_5XFAD

RNA seq assay metadata (syn18876537):

* Minor  
  * Specimen IDs in the RNA seq assay metadata file do not match specimen IDs in the biospecimen metadata file, e.g. "295C\_RNAseq" (assay) vs "295rc" (biospecimen).

Biospecimen metadata (syn18876530):

* Moderate/unknown  
  * There are a lot of specimenIDs that have no associated assay metadata file (only RNAseq has an assay metadata file)  
* Minor  
  * There are a few duplicate rows in the biospecimen metadata file

Individual metadata (syn18880070):

* Minor  
  * Column names are capitalized inconsistently (e.g. "StockNumber" vs "ageDeath", where most other studies use "stockNumber")  
  * Genotype "5XFAD\_hemizygous" is not on the MODEL-AD approved value list. Since this study only has "hemizygous" and "noncarrier", I believe "5XFAD\_hemizygous" should be "5XFAD\_carrier" (but double-check that these two are equivalent).

   
 

## UCI\_ABCA7

RNA seq assay metadata (syn53127285):

* Minor  
  * There are 17 blank columns at the end

General problems for RNA seq (syn53606335):

* Moderate  
  * 4 fastq files do not have a "specimenID" annotation (or most other annotations either): syn53130181, syn53130184, syn53130162, syn53130164  
* Minor  
  * There is a bit of an inconsistency in naming between individual ID and specimen ID for one sample / 2 fastq files (syn53129898 and syn53129905)  
    * The specimenID for these 2 is "11451lh" but individualID is "11452", while for every other file the number for specimen and individual ID match

   
 

## UCI\_hAbeta\_KI

RNA seq assay metadata (syn18816975):

* Minor  
  * Three "platform" column entries are erroneously labeled as NextSeq501, NextSeq502, or NextSeq503, when they should all be NextSeq500

Biospecimen metadata (syn18818785):

* **Major**  
  * Missing a lot of columns that exist in other studies. This file only has "individualID", "specimenID", "organ", and "tissue" and is missing everything else.   
    * Related data is still usable but filling in the rest of this file is a significant effort for the data contributor

Individual metadata (syn18880212):

* Minor  
  * Genotypes do not conform to the MODEL-AD approved values  
  * genotypeBackground "B6N;B6J" doesn't match the MODEL-AD approved values (possibly it should be "C57BL6J:C57BL6N"?  
  * genotypeBackground "C57BL/6N tac/B6" doesn't match anything on the MODEL-AD approved values list 

 

## UCI\_PrimaryScreen

RNA seq assay metadata (syn25754750):

* Moderate  
  * Missing information for specimen "9497rh", which exists in both the biospecimen and individual metadata files. 

Individual metadata (syn25872020):

* Minor  
  * Genotypes do not conform to the MODEL-AD approved values

   
 

## UCI\_Trem2\_Cuprizone

RNA seq assay metadata (syn50996285):

* Minor  
  * There is one extra blank column at the end

Individual metadata (syn50876848):

* Moderate  
  * A lot of missing values for "modelSystemName"

   
 

## UCI\_Trem2-R47H\_NSS

Individual metadata (syn27147690):

* Moderate  
  * 1 sample is missing a value for "sex": TMF20776lh  
  * a lot of missing values for "modelSystemName"

   
   
