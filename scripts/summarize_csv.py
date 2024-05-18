import pandas as pd
import os

def summarize_csv(file_path):
    """Reads a CSV file and prints a summary of its contents."""
    # Check if the file exists
    if os.path.exists(file_path):
        # Read the CSV data into a pandas DataFrame
        df = pd.read_csv(file_path)
        
        # Display column summaries and the first few entries
        print(f"Summary for {os.path.basename(file_path)}:")
        print(f"Columns: {df.columns.tolist()}")
        print(f"First few entries:\n{df.head()}\n")
    else:
        print(f"File {file_path} does not exist.")

# Base directory for temporary files
base_dir = "temp/"

# Filenames of the CSV files
csv_files = ["Template.csv", "Dictionary.csv", "Values.csv"]

# Read and summarize each CSV file
for file in csv_files:
    summarize_csv(os.path.join(base_dir, file))
