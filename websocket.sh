#!/bin/bash

#Ask for which file
#read -p "Which file: "  FILE_NAME

# Ask for password securely
read -s -p "Enter decryption password: " SCRIPT_PASS
echo

# Download and decrypt the encrypted script, then execute it
curl -s "https://raw.githubusercontent.com/tuanna-git/public/main/websocket.sh.enc" | openssl enc -aes-256-cbc -d -pbkdf2 -salt -pass pass:"$SCRIPT_PASS" | bash
