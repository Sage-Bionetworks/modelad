import os

def find_csv_files(directory):
    """Recursively find all CSV files in the specified directory."""
    csv_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.csv'):
                full_path = os.path.join(root, file)
                csv_files.append(full_path)
    return csv_files

def extract_module_name(csv_file_path):
    """Extracts a meaningful module name from the CSV file path."""
    # Split the path into parts
    parts = csv_file_path.split(os.sep)
    # Get the parent directory and the file name without extension
    parent_dir = os.path.basename(os.path.dirname(csv_file_path))
    file_name = os.path.splitext(os.path.basename(csv_file_path))[0]
    module_name = f"{parent_dir}/{file_name}"
    return module_name

def main():
    directory = '~/github/data-models/modules'
    # Expand the tilde to the user's home directory
    expanded_directory = os.path.expanduser(directory)
    csv_files = find_csv_files(expanded_directory)
    csv_files.sort()  # Sort files alphabetically

    # Prepare to write the extracted module names to a file
    with open('./temp/modules.txt', 'w') as f:
        for csv_file in csv_files:
            module_name = extract_module_name(csv_file)
            f.write(f"{module_name}\n")
            print(module_name)  # Also print to console for immediate feedback

if __name__ == "__main__":
    main()
