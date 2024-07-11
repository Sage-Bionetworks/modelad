library(httr)

url <- "https://github.com/Sage-Bionetworks/synapseAnnotations/blob/master/terms/neuro/modelSystemName.json"

response <- GET(url)

if (response$status_code == 200) {
  file <- tempfile()
  writeBin(content(response, "raw"), file)
  
  # Load the file into R
  modelSystemName <- read.json(file)
  
  # Print the contents of the file
  print(modelSystemName)
} else {
  stop("Error downloading file")
}


# # Get the URL of the JSON file from GitHub
# 
# url2 <- "https://github.com/Sage-Bionetworks/synapseAnnotations/blob/master/terms/neuro/individualCommonGenotype.json"


# read_json_from_url <- function(url) {
#   # Check if the URL is valid
#   if (!is.character(url) || nchar(url) == 0) {
#     stop("Please provide a valid URL.")
#   }
#   
#   # Get the JSON data from the URL
#   response <- httr::GET(url)
#   
#   # Check if the response was successful
#   if (response$status_code != 200) {
#     stop("The request to the URL failed.")
#   }
#   
#   # Convert the JSON data to a list
#   data <- jsonlite::fromJSON(httr::content(response, "text"))
#   
#   # Return the data
#   return(data)
# }

a <- read_json_from_url(url1)


# 
# # Read the JSON file
# json_data <- read_json(url1)
# json_data <- read_json(url2)
# 
# # Create a data frame with the const, description, and source columns
# data <- data.frame(
#   const = json_data$anyOf[[1]]$const,
#   description = json_data$anyOf[[1]]$description,
#   source = json_data$anyOf[[1]]$source
# )
# 
# # Write the data frame to a CSV file
# write_csv(data, "data.csv")
# 
# 
# # # Loop over the anyOf components
# # for (anyOf_component in json_data$anyOf) {
# #   
# #   # Create a new row in the data frame
# #   new_row <- data.frame(
# #     const = anyOf_component$const,
# #     description = anyOf_component$description,
# #     source = anyOf_component$source
# #   )
# #   
# #   # Add the new row to the data frame
# #   df <- rbind(df, new_row)
# #   
# # }
# # 
# # # Write the data frame to a CSV file
# # write.csv(df, "data.csv")