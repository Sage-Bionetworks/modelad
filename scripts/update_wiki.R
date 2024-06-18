# update_wiki.R

library(stringr)

clean_formatting <- function(markdown_content) {
  pattern <- "<em1[^>]*>"
  clean_content <- str_replace_all(markdown_content, pattern, "")
  clean_content <- str_replace_all(clean_content, "<em>|</em>", "")
  return(clean_content)
}

convert_and_update_wiki <- function(file_name, file_mappings, dry_run = TRUE) {
  wiki_project <- file_mappings[[file_name]]
  doc_path <- file.path("modelad/data/docs", file_name)
  output_file <- sub(".docx$", ".md", doc_path)

  system(paste("pandoc -f docx -t markdown_strict --wrap=none '", doc_path, "' -o '", output_file, "'"))

  markdown_content <- read_file(output_file)
  cleaned_content <- clean_formatting(markdown_content)
  write_file(cleaned_content, output_file)

  if (dry_run) {
    message("Dry run: Wiki update prepared for file: ", file_name)
    return()
  }

  wiki_object <- tryCatch(synGetWiki(wiki_project), error = function(e) NULL)
  existing_content <- if (!is.null(wiki_object)) wiki_object$markdown else ""

  if (existing_content == "") {
    wiki <- Wiki(owner = wiki_project, markdownFile = output_file)
    synStore(wiki)
    message("Wiki updated for project: ", wiki_project)
  } else {
    message("Wiki already has content. Skipping update for project: ", wiki_project)
  }
}
