#!/bin/bash
set -e pipefail

echo "Installing MongoDB Exporter..."

# Create a system user for mongodb_exporter
useradd --no-create-home --shell /bin/false mongodb_exporter || true

# Download MongoDB Exporter (using latest stable version)
EXPORTER_VERSION="0.40.0"
wget https://github.com/percona/mongodb_exporter/releases/download/v${EXPORTER_VERSION}/mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract and install
tar xvzf mongodb_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz
mv mongodb_exporter-${EXPORTER_VERSION}.linux-amd64/mongodb_exporter /usr/local/bin/
chown mongodb_exporter:mongodb_exporter /usr/local/bin/mongodb_exporter

# Cleanup
rm -rf mongodb_exporter-${EXPORTER_VERSION}.linux-amd64*

# Create systemd service file
cat <<EOF > /etc/systemd/system/mongodb_exporter.service
[Unit]
Description=MongoDB Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=mongodb_exporter
Group=mongodb_exporter
Type=simple
ExecStart=/usr/local/bin/mongodb_exporter --mongodb.uri=mongodb://localhost:27017

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, start and enable the service
systemctl daemon-reload
systemctl start mongodb_exporter
systemctl enable mongodb_exporter

echo "MongoDB Exporter installed and running on port 9216"
systemctl --no-pager status mongodb_exporter