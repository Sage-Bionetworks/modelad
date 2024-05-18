def read_module_names(file_path):
    """Reads module names from a given file into a list."""
    try:
        with open(file_path, 'r') as file:
            return [line.strip() for line in file if line.strip()]
    except FileNotFoundError:
        print(f"Error: File not found {file_path}")
        return []

def read_keys(file_path):
    """Reads a list of keys from a given file into a list."""
    try:
        with open(file_path, 'r') as file:
            return [line.strip() for line in file if line.strip()]
    except FileNotFoundError:
        print(f"Error: File not found {file_path}")
        return []

def compare_keys_to_modules(keys, modules):
    """Finds which keys are not fully represented in any of the module names."""
    found_keys = set()
    for key in keys:
        for module in modules:
            if key in module:
                found_keys.add(key)
                break
    new_keys = set(keys) - found_keys
    return sorted(new_keys)  # Return a sorted list of keys not found

def main():
    module_file = 'temp/modules.txt'  # Ensure the path is correct
    keys_file = 'temp/keys.txt'       # Ensure the path is correct

    existing_modules = read_module_names(module_file)
    potential_keys = read_keys(keys_file)

    # Perform a detailed search and sort the output if needed
    keys_to_add = compare_keys_to_modules(potential_keys, existing_modules)

    # Output results
    if keys_to_add:
        print("New keys to add to the data model:")
        for key in keys_to_add:
            print(key)
    else:
        print("No new keys to add; all keys are already present in the model.")

if __name__ == "__main__":
    main()
