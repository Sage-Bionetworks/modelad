library(synapser)
synLogin()

# https://www.synapse.org/#!Synapse:syn35993551 
# >> 
# https://www.synapse.org/#!Synapse:syn51535045


# Add a local file to an existing project (syn12345) on Synapse
file <- File(path='docker/rstudio/Dockerfile', parentId='syn26968776')
file <- synStore(file)
file <- File(path='docker/rstudio/docker-compose.yml', parentId='syn26968776')
file <- synStore(file)
# Move individual files
foo <- synGet('syn51667928', downloadFile = FALSE)
foo$properties$parentId <- 'syn51667945'
synStore(foo)
foo <- synGet('syn51667937', downloadFile = FALSE)
foo$properties$parentId <- 'syn51667945'
synStore(foo)
# Move folder
foo <- synGet('syn51667945', downloadFile = FALSE)
foo$properties$parentId <- 'syn51667983'
synStore(foo)




# AD-EL 49
# Hey Catrina,
# 
# Sure, here is the code to move a file or folder in Synapse:
#   
#   # Fetch the file/folder to move
#   foo <- synGet(file_id, downloadFile = FALSE)
# # Change the parentId to the new location
# foo$properties$parentId <- new_parent_id # 'syn51535045' for LOAD2 staging
# # Store the file/folder to move it
# synStore(foo)
# 
# # Synapse Documentation:
# https://help.synapse.org/docs/Uploading-and-Organizing-Data-Into-Projects,-Files,-and-Folders.2048327716.html
# 
