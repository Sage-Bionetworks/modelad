# From Narges Rezaie @ UCI: 
# This GEO contains SPLiT-seq files we wish to upload to Synapse.
# There is also an additional downstream analysis that we would like to upload as well.
# https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE255965
# https://zenodo.org/records/10724706?token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6IjhlMTA4ZWFiLWQ1MjgtNGQ4Yy1iYjE5LWU5ZWY0MzM4MDVmNyIsImRhdGEiOnt9LCJyYW5kb20iOiIwZjdhNzg4ZDExMzYxMTM5MzQwODk4NGYwOWRkYzRlOSJ9.2qzF6Y7gO_RUEtQQaW7isi02FcaoxdjT664NU-pMeJJdc2ViFhRTVBi485NlHYRKXGzmrSCdZO1n8LzL0RRspg
---
title: "GEO Data Extraction and Visualization"
author: "Rich"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)


# Define the URL
url <- "https://zenodo.org/record/10724706/files/results_single_cell_data.zip?download=1"

# Download the file
download.file(url, destfile = "results_single_cell_data.zip")

# Unzip the file
unzip("results_single_cell_data.zip", exdir = "single_cell_data")

# Install and load required packages
if (!require("yaml")) install.packages("yaml", repos = "http://cran.us.r-project.org")
library(yaml)

# Load the YAML file
yaml_file <- "single_cell_data/metadata.yaml"
metadata <- yaml::read_yaml(yaml_file)

# Display the metadata
print(metadata)

# Install and load required packages
if (!require("rhdf5")) BiocManager::install("rhdf5")
library(rhdf5)

# Load the HDF5 file
hdf5_file <- "single_cell_data/data.h5"

# List contents of the HDF5 file
h5ls(hdf5_file)

# Load a dataset from the HDF5 file
dataset <- h5read(hdf5_file, "dataset_name")  # replace 'dataset_name' with the actual dataset name

# View the first few rows of the dataset
head(dataset)


# Install and load ggplot2
if (!require("ggplot2")) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
library(ggplot2)

# Assuming 'dataset' is a data frame, plot the data
# Replace 'x_variable' and 'y_variable' with actual variable names
ggplot(dataset, aes(x = x_variable, y = y_variable)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Data Visualization", x = "X Variable", y = "Y Variable")
