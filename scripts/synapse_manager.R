library(synapser)
library(dplyr)
library(readr)
library(janitor)

SynapseManager <- setRefClass(
  "SynapseManager",
  fields = list(syn = "ANY"),
  methods = list(
    initialize = function() {
      synLogin()
      syn <<- synGet()
    },

    createFileviewSchema = function(name, parentId, scopeId) {
      schema <- EntityViewSchema(
        name = name,
        parent = parentId,
        scopes = scopeId,
        includeEntityTypes = list(EntityViewType$FILE),
        addDefaultViewColumns = TRUE,
        addAnnotationColumns = FALSE
      )
      fileview <- synStore(schema)
      return(fileview$properties$id)
    },

    queryFileview = function(fileviewId) {
      query_result <- synTableQuery(paste("SELECT * FROM", fileviewId))
      df <- read_csv(query_result$filepath)
      return(df)
    },

    removeColumns = function(df, startCol, endCol) {
      df <- df %>% select(-c(startCol:endCol))
      return(df)
    },

    read_and_preprocess = function(synId) {
      df <- read_csv(synGet(synId)$path) %>%
        mutate(across(where(is.character), as.character)) %>%
        remove_empty(c("rows", "cols"))
      return(df)
    },

    coalesce_join = function(original, update, by) {
      joined <- full_join(original, update, by = by, suffix = c(".x", ".y"))
      colnames <- union(names(original), names(update))

      for (col in colnames) {
        if (paste0(col, ".x") %in% names(joined) & paste0(col, ".y") %in% names(joined)) {
          joined[[col]] <- coalesce(joined[[paste0(col, ".x")]], joined[[paste0(col, ".y")]])
          joined <- joined %>% select(-c(paste0(col, ".x"), paste0(col, ".y")))
        }
      }
      return(joined)
    }
  )
)
