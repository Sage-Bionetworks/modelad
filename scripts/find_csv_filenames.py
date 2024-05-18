import os

def find_csv_files(directory):
    csv_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.csv'):
                csv_files.append(os.path.join(root, file))
    return csv_files

def main():
    directory = '~/github/data-models/modules'
    # Expand the tilde to the user's home directory
    expanded_directory = os.path.expanduser(directory)
    csv_files = find_csv_files(expanded_directory)
    print(csv_files)
    with open('./temp/csv_files.txt', 'w') as f:
        for file in csv_files:
            f.write(f"{file}\n")

if __name__ == "__main__":
    main()
