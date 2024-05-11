#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update package repositories and install NGINX
sudo apt update -y
sudo apt install nginx -y

# Remove existing content from NGINX's default HTML directory
sudo rm -rf /var/www/html/*

# Clone the ecomm repository from GitHub
sudo git clone https://github.com/ravi2krishna/ecomm.git /tmp/ecomm

# Copy the contents of the ecomm directory to NGINX's HTML directory
sudo cp -r /tmp/ecomm/* /var/www/html

# Restart NGINX to apply changes
sudo systemctl restart nginx


