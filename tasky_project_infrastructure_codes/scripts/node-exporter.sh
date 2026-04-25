#!/usr/bin/env bash
set -e

### CONFIG ###
NODE_EXPORTER_VERSION="1.10.2"
NODE_EXPORTER_USER="node_exporter"
INSTALL_DIR="/etc/node_exporter"
TMP_DIR="/tmp/node-exporter-install"

echo "==> Installing dependencies"
apt-get update -y
apt-get install -y wget tar

echo "==> Creating node_exporter system user (if missing)"
if ! id ${NODE_EXPORTER_USER} >/dev/null 2>&1; then
  useradd -r -s /sbin/nologin ${NODE_EXPORTER_USER}
fi

echo "==> Preparing temp directory"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

echo "==> Downloading node_exporter ${NODE_EXPORTER_VERSION}"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "==> Extracting node_exporter"
tar xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "==> Installing node_exporter"
rm -rf "${INSTALL_DIR}"
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 "${INSTALL_DIR}"

echo "==> Setting ownership"
chown -R ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} "${INSTALL_DIR}"

echo "==> Creating systemd service"
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_USER}
Type=simple
ExecStart=${INSTALL_DIR}/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reloading systemd"
systemctl daemon-reexec
systemctl daemon-reload

echo "==> Enabling and starting node_exporter"
systemctl enable node_exporter
systemctl restart node_exporter

echo "==> Node Exporter installation complete"
echo "==> Metrics available at: http://<server-ip>:9100/metrics"
