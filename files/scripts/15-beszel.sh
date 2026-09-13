#!/usr/bin/env bash
set -euo pipefail

# NOTE: Test fleet only. Universal token/key hardcoded here by deliberate
# risk acceptance — rotate via hub /settings/tokens before promoting
# beyond a handful of test devices. See build repo README for context.

BESZEL_HUB_URL="${BESZEL_HUB_URL:-http://159.195.72.252:8090}"
BESZEL_TOKEN="${BESZEL_TOKEN:-5ed8f94b-d6fd-433a-9940-e21410962e51}"
BESZEL_KEY="${BESZEL_KEY:-ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPzyy+/BPYuDg43zmnaGYGHUjLQVxHjpV8h2rkbnZ5U}"

echo "Installing beszel-agent..."

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
esac

curl -sSLf "https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_linux_${ARCH}.tar.gz" \
  -o /tmp/beszel-agent.tar.gz
tar -xzf /tmp/beszel-agent.tar.gz -C /usr/bin/ beszel-agent
rm -f /tmp/beszel-agent.tar.gz

cat > /usr/lib/systemd/system/beszel-agent.service << EOF
[Unit]
Description=Beszel Agent Service
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/beszel-agent
StateDirectory=beszel-agent
Environment="HUB_URL=${BESZEL_HUB_URL}"
Environment="TOKEN=${BESZEL_TOKEN}"
Environment="KEY=${BESZEL_KEY}"
Restart=on-failure
RestartSec=5
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=read-only

[Install]
WantedBy=multi-user.target
EOF

systemctl enable beszel-agent.service

echo "beszel-agent installed, configured, and enabled."
