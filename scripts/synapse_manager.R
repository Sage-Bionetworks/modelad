# Load necessary libraries
library(synapser)
library(dplyr)
library(readr)
library(janitor)
library(yaml)

# Define SynapseManager class
SynapseManager <- setRefClass(
  "synMgr",
  methods = list(
    initialize = function() synLogin(),

    createFileviewSchema = function(name, parentId, scopeId) {
      schema <- EntityViewSchema(
        name = name,
        parent = parentId,
        scopes = scopeId,
        includeEntityTypes = list(EntityViewType$FILE),
        addDefaultViewColumns = TRUE,
        addAnnotationColumns = FALSE
      )
      synStore(schema)$properties$id
    },

    queryFileview = function(fileviewId) {
      query_result <- synTableQuery(paste("SELECT * FROM", fileviewId))
      read_csv(query_result$filepath) %>% clean_names()
    },

    download_metadata = function(fileview_id) {
      query_result <- synTableQuery(paste("SELECT * FROM", fileview_id))
      read_csv(query_result$filepath) %>% clean_names()
    },

    upload_metadata = function(fileview_id, metadata_df) {
      table_final <- Table(fileview_id, metadata_df)
      synStore(table_final)
    },

    read_config = function(config_path) yaml::read_yaml(config_path)
  )
)
