#!/bin/bash

# Ask for password securely
read -s -p "Enter decryption password: " SCRIPT_PASS
echo

# Download and decrypt the encrypted script, then execute it
curl -s "https://raw.githubusercontent.com/tuanna-git/public/main/deploy_wordpress.sh" | openssl enc -aes-256-cbc -d -pbkdf2 -salt -pass pass:"$SCRIPT_PASS" | bash
