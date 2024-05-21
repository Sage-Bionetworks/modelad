import json
import pandas as pd
from pyld import jsonld

def load_jsonld(jsonld_path):
    """Load and return JSON-LD data from a file."""
    with open(jsonld_path, 'r') as file:
        return json.load(file)

def verify_jsonld(data):
    """Verify JSON-LD syntax and compliance."""
    jsonld.expand(data)
    print("JSON-LD is valid and standards compliant.")
    return True

def jsonld_to_csv(data, csv_output_path):
    """Convert JSON-LD data to CSV and save it."""
    df = pd.json_normalize(data['@graph'])
    df.rename(columns={'@id': 'ID'}, inplace=True)
    df.to_csv(csv_output_path, index=False)
    print(f"CSV file has been saved to {csv_output_path}")

def main(jsonld_path, csv_output_path):
    """Main function to load, verify, and convert JSON-LD data to CSV."""
    data = load_jsonld(jsonld_path)
    if verify_jsonld(data):
        jsonld_to_csv(data, csv_output_path)

# Example usage
if __name__ == "__main__":
    main('../example.model.jsonld', '../test.model.csv')
