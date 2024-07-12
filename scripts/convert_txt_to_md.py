import os

# Define the base path for the text files
base_path = os.path.expanduser("~/Library/Application Support/Notational Data")
output_path = os.path.expanduser("~/Library/CloudStorage/Dropbox/logseq/pages")

# List all .txt files in the directory
txt_files = [f for f in os.listdir(base_path) if f.endswith('.txt')]

def convert_txt_to_md(txt_file):
    # Define the full path for the .txt file
    txt_path = os.path.join(base_path, txt_file)
    
    # Read the content of the .txt file
    with open(txt_path, 'r') as file:
        content = file.read()
    
    # Define the .md file path
    md_file = txt_file.replace('.txt', '.md')
    md_path = os.path.join(output_path, md_file)
    
    # Write the content to the .md file
    with open(md_path, 'w') as file:
        file.write(content)
    
    # Optionally, delete the original .txt file
    # os.remove(txt_path)
    
    print(f"Converted: {txt_file} to {md_file}")

# Apply the conversion to all .txt files
for txt_file in txt_files:
    convert_txt_to_md(txt_file)

print("Conversion completed.")
