coalesce_join <- function(x, y, 
                          by = NULL, suffix = c(".x", ".y"), 
                          join = dplyr::full_join, ...) {

  # Join the data frames
  joined <- join(x, y, by = by, suffix = suffix, ...)

  # Get the names of the desired columns
  cols <- union(names(x), names(y))

  # Get the names of the columns that need to be coalesced
  to_coalesce <- names(joined)[!names(joined) %in% cols]

  # Get the suffix that was used for each column
  suffix_used <- suffix[ifelse(endsWith(to_coalesce, suffix[1]), 1, 2)]

  # Remove the suffixes and deduplicate the column names
  to_coalesce <- unique(substr(
    to_coalesce, 
    1, 
    nchar(to_coalesce) - nchar(suffix_used)
  ))

  # Coalesce the missing values
  coalesced <- purrr::map_dfc(to_coalesce, ~dplyr::coalesce(
    joined[[paste0(.x, suffix[1])]], 
    joined[[paste0(.x, suffix[2])]]
  ))

  # Set the names of the coalesced columns
  names(coalesced) <- to_coalesce

  # Bind the coalesced columns to the joined data frame
  bind_cols(joined, coalesced)[cols]
}
