# markdown_utils.R: Functions for handling Markdown content

library(stringr)

# Function to clean Markdown formatting
clean_formatting <- function(markdown_content) {
    clean_content <- str_replace_all(markdown_content, "<em1[^>]*>", "")
    str_replace_all(clean_content, "<em>|</em>", "")
}
