#!/bin/bash

# Scan for all .sh.enc files in the folder
files=(*.sh.enc)

# Check if there are any encrypted scripts
if [ ${#files[@]} -eq 0 ]; then
    echo "No encrypted .sh.enc files found!"
    exit 1
fi

# Display available encrypted scripts
echo "🔒 Available encrypted scripts:"
for i in "${!files[@]}"; do
    echo "$((i+1)). ${files[i]}"
done

# Ask user to select a script
read -p "Enter the number of the script to run: " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
    echo "Invalid choice. Exiting."
    exit 1
fi

# Get the selected script filename
selected_file="${files[$((choice-1))]}"

# Ask for decryption password once
read -s -p "Enter decryption password: " SCRIPT_PASS
echo

# Execute the selected encrypted script
openssl enc -aes-256-cbc -d -pbkdf2 -salt -pass pass:"$SCRIPT_PASS" -in "$selected_file" | bash