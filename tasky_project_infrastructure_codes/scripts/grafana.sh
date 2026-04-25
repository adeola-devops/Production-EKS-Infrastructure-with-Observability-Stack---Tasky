#!/usr/bin/env bash
set -e

### CONFIG ###
GRAFANA_VERSION="12.3.2"
INSTALL_DIR="/usr/local/grafana"
GRAFANA_USER="grafana"
TMP_DIR="/tmp/grafana-install"

echo "==> Installing dependencies"
apt-get update -y
apt-get install -y wget tar adduser libfontconfig1 musl

echo "==> Creating grafana system user (if missing)"
if ! id grafana >/dev/null 2>&1; then
  useradd -r -s /bin/false grafana
fi

echo "==> Preparing temp directory"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

echo "==> Downloading Grafana ${GRAFANA_VERSION}"
wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz

echo "==> Extracting Grafana"
tar -xzf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz

echo "==> Installing to ${INSTALL_DIR}"
rm -rf "${INSTALL_DIR}"
mv grafana-${GRAFANA_VERSION} "${INSTALL_DIR}"

echo "==> Creating required directories"
mkdir -p ${INSTALL_DIR}/{data,logs,plugins}

echo "==> Creating grafana.ini from sample (binary install requirement)"
cp ${INSTALL_DIR}/conf/sample.ini ${INSTALL_DIR}/conf/grafana.ini

echo "==> Setting ownership"
chown -R ${GRAFANA_USER}:${GRAFANA_USER} "${INSTALL_DIR}"

echo "==> Creating systemd service"
cat > /etc/systemd/system/grafana-server.service <<EOF
[Unit]
Description=Grafana Server
After=network.target

[Service]
Type=simple
User=${GRAFANA_USER}
Group=${GRAFANA_USER}
ExecStart=${INSTALL_DIR}/bin/grafana server \
  --homepath=${INSTALL_DIR} \
  --config=${INSTALL_DIR}/conf/grafana.ini
Restart=on-failure
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reloading systemd"
systemctl daemon-reexec
systemctl daemon-reload

echo "==> Enabling and starting Grafana"
systemctl enable grafana-server
systemctl restart grafana-server

echo "==> Grafana installation complete"
echo "==> Access: http://<server-ip>:3000"
echo "==> Default login: admin / admin"