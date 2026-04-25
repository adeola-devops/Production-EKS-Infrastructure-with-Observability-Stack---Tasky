#!/bin/bash
set -e

 # Install prerequisites
echo "installing prerequisites"
sudo apt-get update -y 
sudo apt-get install gnupg jq curl -y

# -------------------------------
# Install AWS CLI
# -------------------------------
sudo apt-get install -y unzip python3-pip
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo rm -rf awscliv2.zip 

# Add MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

 # Add MongoDB repository (using jammy repo for Ubuntu 24.04 noble)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start and enable MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Variables
MONGO_CONF="/etc/mongod.conf"

# Update bindIp to allow external connections
sudo sed -i 's/^  bindIp: .*/  bindIp: 0.0.0.0/' $MONGO_CONF

# Restart MongoDB
sudo systemctl restart mongod

# Wait a few seconds for MongoDB to start
sleep 5

# Retrieve secret from aws secret manager
SECRET=$(aws secretsmanager get-secret-value --secret-id mongodb/credentials --region us-east-1 --query SecretString --output text)
USERNAME=$(echo $SECRET | jq -r .username)
PASSWORD=$(echo $SECRET | jq -r .password)

# Create user FIRST
mongosh <<EOF
use admin
db.createUser({
  user: "$USERNAME",
  pwd: "$PASSWORD",
  roles: [ { role: "root", db: "admin" } ]
})
EOF

# Enable authentication
security:
  authorization: enabled

# Restart MongoDB with auth enabled
sudo systemctl restart mongod

# Create admin user if not exists

echo "MongoDB is ready.