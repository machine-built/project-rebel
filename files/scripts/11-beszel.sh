# download agent, create then enable service

curl -sL "https://github.com/henrygd/beszel/releases/download/v0.19.0/beszel-agent_linux_amd64.tar.gz" \
    | tar -xz beszel-agent -C /usr/bin/ \
 && cat > /usr/lib/systemd/system/beszel-agent.service << 'EOF'
[Unit]
Description=Beszel Agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/beszel-agent
Environment="LISTEN=45876"
Environment="HUB_URL=http://159.195.72.252:8090"
Environment="TOKEN=5ed8f94b-d6fd-433a-9940-e21410962e51"
Environment="KEY=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPzyy+/BPYuDg43zmnaGYGHUjLQVxHjpV8h2rkbnZ5U"
Restart=on-failure
RestartSec=5
StateDirectory=beszel-agent
ProtectSystem=strict
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable beszel-agent.service
