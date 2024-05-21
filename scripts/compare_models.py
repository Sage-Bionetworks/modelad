import pandas as pd

def load_csv(file_path):
    """Load CSV file into a DataFrame."""
    return pd.read_csv(file_path)

def compare_column_names(template_df, data_model_df):
    """Compare column names of the template and existing data model."""
    template_columns = set(template_df.columns)
    data_model_columns = set(data_model_df.columns)

    # Identify columns that are in the template but not in the existing data model
    new_columns = template_columns - data_model_columns
    # Identify columns that are in the existing data model but not in the template
    deleted_columns = data_model_columns - template_columns
    # Identify common columns (these may be candidates for further comparison)
    common_columns = template_columns & data_model_columns

    return new_columns, deleted_columns, common_columns

def main(template_path, data_model_path):
    """Main function to load, compare, and display differences in column names."""
    # Load the CSV files
    template_df = load_csv(template_path)
    data_model_df = load_csv(data_model_path)

    # Compare column names
    new_columns, deleted_columns, common_columns = compare_column_names(template_df, data_model_df)

    # Display results
    print("New Columns in Template:")
    print(new_columns)

    print("\nDeleted Columns from Data Model:")
    print(deleted_columns)

    print("\nCommon Columns:")
    print(common_columns)

# Example usage
if __name__ == "__main__":
    template_path = './temp/Template.csv'
    data_model_path = '~/GitHub/data-models/AD.model.csv'
    main(template_path, data_model_path)
