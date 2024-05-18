import pandas as pd
import os

def read_and_sort_keys(filepath):
    """Reads the first column of a CSV file, extracts unique keys, and sorts them."""
    try:
        # Read the CSV, assuming keys are in the first column
        df = pd.read_csv(filepath)
        keys = sorted(df.iloc[:, 0].unique())  # Sort the unique keys
        return keys
    except FileNotFoundError:
        print(f"Error: The file {filepath} does not exist.")
        return []
    except pd.errors.EmptyDataError:
        print(f"Error: The file {filepath} is empty or corrupt.")
        return []
    except Exception as e:
        print(f"An unexpected error occurred: {str(e)}")
        return []

def main():
    filepath = 'temp/Template.csv'  # Make sure this path is correct and accessible
    sorted_keys = read_and_sort_keys(filepath)

    if sorted_keys:  # Only write to file if there are keys to write
        with open('temp/keys.txt', 'w') as f:
            for key in sorted_keys:
                f.write(f"{key}\n")
    else:
        print("No keys were found to write to the file.")

if __name__ == "__main__":
    main()
