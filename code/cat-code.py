import os

def concatenate_code_files(input_dir, output_file):
    
    search recursively through all directories 
    r_files = [f for f in os.listdir(input_dir) if f.endswith('.R')] or '.py'
    
    if not r_files:
        print("No R files found.")
        return
    
    with open(output_file, 'w') as outfile:
        for file in r_files:
            # Add a header with the file name and concatenate its content
            outfile.write(f"# File: {file}\n")
            with open(os.path.join(input_dir, file), 'r') as infile:
                outfile.write(infile.read() + "\n")
    
    print(f"Concatenated all R files into: {output_file}")

# Example usage with the updated paths
concatenate_r_files("modelad/projects", "modelad/projects/concatenated_code.text")
