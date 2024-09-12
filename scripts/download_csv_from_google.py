import requests
import os
import json

def download_csv_from_google_sheets(sheet_url, gid, output_filename):
    """Downloads a CSV file from a specified Google Sheets URL and gid."""
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_filename), exist_ok=True)
    
    # Construct the CSV export URL
    csv_url = f"{sheet_url.replace('/edit#gid=', '/export?format=csv&gid=')}"
    
    # Send a GET request to the CSV URL
    response = requests.get(csv_url)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Save the CSV data to a file
        with open(output_filename, 'wb') as file:
            file.write(response.content)
        print(f"CSV file has been downloaded and saved as '{output_filename}'.")
    else:
        print(f"Failed to download CSV. HTTP Status Code: {response.status_code}")

def load_config(config_file):
    """Loads the JSON configuration file."""
    with open(config_file, 'r') as file:
        return json.load(file)

# Load configuration
config = load_config('tabs_config.json')

# Download CSVs for each tab
for tab_name, tab_info in config.items():
    url = tab_info['url']
    gid = url.split("gid=")[1]
    filename = tab_info['filename']
    download_csv_from_google_sheets(url, gid, filename)
