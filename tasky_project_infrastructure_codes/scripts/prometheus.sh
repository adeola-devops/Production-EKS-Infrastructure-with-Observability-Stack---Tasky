#!/usr/bin/env bash
set -e

### CONFIG ###
PROM_VERSION="2.47.0"
PROM_USER="prometheus"
INSTALL_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
TMP_DIR="/tmp/prometheus-install"

echo "==> Installing dependencies"
apt-get update -y
apt-get install -y wget tar

echo "==> Creating prometheus system user and group (if missing)"
if ! getent group prometheus >/dev/null; then
  groupadd --system prometheus
fi

if ! id prometheus >/dev/null 2>&1; then
  useradd -s /sbin/nologin --system -g prometheus prometheus
fi

echo "==> Creating directories"
mkdir -p ${INSTALL_DIR}
mkdir -p ${DATA_DIR}

echo "==> Preparing temp directory"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

echo "==> Downloading Prometheus ${PROM_VERSION}"
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "==> Extracting Prometheus"
tar xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROM_VERSION}.linux-amd64

echo "==> Installing Prometheus binaries"
mv prometheus /usr/local/bin/
mv promtool /usr/local/bin/

echo "==> Installing Prometheus config files"
mv consoles ${INSTALL_DIR}
mv console_libraries ${INSTALL_DIR}
mv prometheus.yml ${INSTALL_DIR}

echo "==> Setting ownership"
chown ${PROM_USER}:${PROM_USER} /usr/local/bin/prometheus
chown ${PROM_USER}:${PROM_USER} /usr/local/bin/promtool
chown -R ${PROM_USER}:${PROM_USER} ${INSTALL_DIR}
chown -R ${PROM_USER}:${PROM_USER} ${DATA_DIR}

echo "==> Creating systemd service"
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=${PROM_USER}
Group=${PROM_USER}
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=${INSTALL_DIR}/prometheus.yml \
  --storage.tsdb.path=${DATA_DIR} \
  --web.console.templates=${INSTALL_DIR}/consoles \
  --web.console.libraries=${INSTALL_DIR}/console_libraries
Restart=on-failure
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reloading systemd"
systemctl daemon-reexec
systemctl daemon-reload

echo "==> Enabling and starting Prometheus"
systemctl enable prometheus
systemctl restart prometheus

echo "==> Prometheus installation complete"
echo "==> Access: http://<server-ip>:9090"
