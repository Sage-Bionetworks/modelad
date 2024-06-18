Here is the is

generate_config_template <- function(template_path) {
  template <- list(
    studyID = "example_study_id",
    studyName = "Example Study Name",
    program = "Example Program"
  )

  yaml::write_yaml(template, template_path)
  print(sprintf("Configuration template saved to %s", template_path))
}

# Uncomment to generate a template
# generate_config_template("/path/to/save/template.yaml")
