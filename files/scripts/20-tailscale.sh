#!/usr/bin/env bash
set -xeuo pipefail

# Repo ships at files/system/etc/yum.repos.d/tailscale.repo (enabled=0)
dnf install -y --enablerepo=tailscale-stable tailscale

systemctl enable tailscaled.service
