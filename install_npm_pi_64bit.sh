#!/bin/bash

set -e

echo "==> Updating system..."
sudo apt update && sudo apt upgrade -y

echo "==> Installing Docker and Docker Compose plugin..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

echo "==> Installing Docker Compose CLI plugin..."
sudo apt install -y docker-compose-plugin

echo "==> Creating project directory..."
mkdir -p ~/nginx-proxy-manager && cd ~/nginx-proxy-manager

echo "==> Writing docker-compose.yml (no 'version')..."
cat <<EOF > docker-compose.yml
services:
  app:
    image: jc21/nginx-proxy-manager:latest
    restart: always
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

echo "==> Done setting up. Please log out and back in (or reboot) before starting Docker as your user."
echo "👉 To start NGINX Proxy Manager manually later, run:"
echo "   cd ~/nginx-proxy-manager && docker compose up -d"
