#!/bin/bash
apt-get update -y

# Install Nginx
apt-get install -y nginx

# Enable and start Nginx
systemctl enable --now nginx

# Create a simple landing page
echo "Hello from Terraform by Prakhar..!" | sudo tee /var/www/html/index.html 
