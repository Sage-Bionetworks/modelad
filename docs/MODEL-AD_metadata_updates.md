## MODEL-AD RNA Sequencing Metadata Update Process

This document provides a structured guide for contributors to update metadata for specific studies, ensuring alignment with approved standards.

For more detail, see Jaclyn Beck's summary of RNA Sequencing issues: [RNAseq_metadata_issues](RNAseq_metadata_issues.md)

**Task Summary**

For each study, please:

1. Review the study-specific sections below.
2. Update your metadata, focusing on the specific IDs and details mentioned.
3. Ensure your updates align with the approved values listed in the metadata template and MODEL-AD documentation:
  - [Contribute Data to MODEL-AD: A Step-by-Step Guide](https://sagebionetworks.jira.com/wiki/spaces/MOD/pages/2573402701/Contribute+Data+to+MODEL-AD+A+Step-by-Step+Guide)
  - [Mouse Naming Standards](https://sagebionetworks.jira.com/wiki/spaces/MOD/pages/2125201409/Mouse+Naming+Standards)
  - Report any issues or challenges!
4. Download templates from the Data Curator App (DCA). 
    - Go to [DCA](https://dca.app.sagebionetworks.org/)
    - Select DCC > **AD Knowledge Portal**
    - Select Project > **AD Knowledge Portal - Backend**
    - Select Folder > Jax.IU.Pitt_LOAD2 (for example)
    - Select the template to download (eg, individual animal MODEL-AD, biospecimen, etc.)
5. Populate the template with the latest updates of your study metadata
6. Validate your metadata with the Data Curator App (DCA)
7. If needed, resolve any issues so that the metadata complies with the data model. This may require a few iterations to address any issues.
8. Please us know if you have any issues with these steps.

---

### **1. Jax.IU.Pitt_5XFAD**  
- **[Study Link: syn22103212](https://www.synapse.org/#!Synapse:syn22103212)**  

#### **Critical Issues**  
- Missing "ageDeath" and "ageDeathUnits" columns.  
- Some mice missing "dateBirth" or "dateDeath" entries, preventing age calculation.  
- Individuals (e.g., 289904014, 289973785) have "dateDeath" earlier than "dateBirth".

#### **Minor Issues**  
- Extra spaces in "Sex" column entries (e.g., "female ").
  - **AD-DCC - Fix **
  - Verified no extra spaces in annotations, but in CSV
---

### **2. Jax.IU.Pitt_APOE4.Trem2.R47H**  
- **[Study Link: syn18345333](https://www.synapse.org/#!Synapse:syn18345333)**  

#### **Critical Issues**  
- Missing brain RNAseq samples (only blood samples are present).  
- 33 specimen IDs do not exist in biospecimen metadata.  
- 47 samples missing genotype values.  
- 382 unique individual IDs missing from the individual metadata (e.g., 20440, 20456, etc.).

#### **Minor Issues**  
- 922 rows but only 237 unique individual IDs; many rows are duplicates.  
- Genotypes inconsistently labeled (e.g., "APOE4_noncarrier" vs. "APOE4_noncarrier;TREM2R47H_noncarrier").  
- Genotypes don't match the MODEL-AD approved values.

#### **General RNAseq Issue**  
- Fastq files for specimen "251rh" exist, but no corresponding individual or biospecimen metadata.

---

### **3. UCI_3xTg-AD**  
- **[Study Link: syn23532199](https://www.synapse.org/#!Synapse:syn23532199)**  

#### **Minor Issues**  
- Column names inconsistently capitalized (e.g., "StockNumber" vs. "stockNumber").  
- Genotype "3XTg-AD_noncarrier" should be "3xTg-AD_noncarrier" to conform to approved values.  
- Genotype background "B6129" doesn't match approved values.

- **[Biospecimen Metadata: syn23532198](https://www.synapse.org/#!Synapse:syn23532198)**  
  - 15 empty columns at the end of the biospecimen metadata.
  - **AD-DCC - Fix**

---

### **4. UCI_5XFAD**  
- **[Study Link: syn18876537](https://www.synapse.org/#!Synapse:syn18876537)**  

#### **Moderate Issues**  
- Several specimen IDs lack associated assay metadata files.  
- Duplicate rows in biospecimen metadata.

#### **Minor Issues**  
- Specimen IDs in the RNAseq assay metadata file don't match the biospecimen metadata (e.g., "295C_RNAseq" vs. "295rc").  
- Column names in individual metadata inconsistently capitalized (e.g., "StockNumber" vs. "ageDeath").  
- Genotype "5XFAD_hemizygous" should be renamed to "5XFAD_carrier" to align with approved values.

---

### **5. UCI_ABCA7**  
- **[Study Link: syn53127285](https://www.synapse.org/#!Synapse:syn53127285)**  

#### **Moderate Issues**  
- Four fastq files lack "specimenID" annotations (syn53130181, syn53130184, etc.).  
- Inconsistent naming between individual and specimen IDs for two fastq files (syn53129898 and syn53129905).

#### **Minor Issues**  
- RNAseq assay metadata contains 17 blank columns.
- **AD-DCC - Fix**

---

### **6. UCI_PrimaryScreen**  
- **[Study Link: syn25754750](https://www.synapse.org/#!Synapse:syn25754750)**  

#### **Moderate Issues**  
- Missing data for specimen "9497rh" in both RNAseq and individual metadata.

#### **Minor Issues**  
- Genotypes don't match MODEL-AD approved values.

---

### **7. UCI_Trem2-R47H_NSS**  
- **[Study Link: syn27147690](https://www.synapse.org/#!Synapse:syn27147690)**  

#### **Moderate Issues**  
- Missing "sex" value for sample TMF20776lh.  
- Many missing values for "modelSystemName" in individual metadata.

---

### **8. UCI_Trem2_Cuprizone**  
- **[Study Link: syn50996285](https://www.synapse.org/#!Synapse:syn50996285)**  

#### **Moderate Issues**  
- Missing values for "modelSystemName" in individual metadata.

#### **Minor Issues**  
- One extra blank column in RNAseq metadata.
- **AD-DCC - Fix**

---

### **9. UCI_hAbeta_KI**  
- **[Study Link: syn18816975](https://www.synapse.org/#!Synapse:syn18816975)**  

#### **Critical Issues**  
- Missing most columns in the biospecimen metadata (only "individualID", "specimenID", "organ", and "tissue" are present).  

#### **Minor Issues**  
- RNAseq metadata contains incorrect "platform" entries ("NextSeq501", "NextSeq502", etc., should be "NextSeq500").  
- Genotypes in individual metadata don't conform to approved values (e.g., "B6N;B6J" should be "C57BL6J:C57BL6N").  
- Genotype background "C57BL/6N tac/B6" doesn't match approved values.
- **AD-DCC - Fix**
