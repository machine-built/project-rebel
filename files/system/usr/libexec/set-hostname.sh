#!/usr/bin/env bash
# derive a per-device hostname on first boot.
# Usage:
# set-hostname.sh            apply
# set-hostname.sh --dry-run  print the name that would be applied, change nothing
set -euo pipefail

PREFIX="${REBEL_HOST_PREFIX:-rebel}"
SUFFIX_LEN="${REBEL_HOST_SUFFIX_LEN:-6}"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# Reduce any string to lowercase [a-z0-9] so it's always a legal DNS label.
sanitize() { tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]'; }

serial=""
if [[ -r /sys/class/dmi/id/product_serial ]]; then
    serial="$(sanitize < /sys/class/dmi/id/product_serial)"
fi

# Common placeholder values from firmware that are not real serials.
case "$serial" in
    ""|0|none|notspecified|systemserialnumber|default*|tobefilled*|na|n/a)
        serial=""
        ;;
esac

if [[ -n "$serial" ]]; then
    source="dmi-serial"
    suffix="$serial"
else
    source="machine-id"
    suffix="$(sanitize < /etc/machine-id)"
fi

# Take the *last* N characters: serials often share a long common prefix
# within a model line, and the tail is where they differ.
suffix="${suffix: -${SUFFIX_LEN}}"
name="${PREFIX}-${suffix}"

if (( DRY_RUN )); then
    echo "would set hostname: ${name} (source: ${source})"
    exit 0
fi

current="$(hostname)"
if [[ "$current" == "$name" ]]; then
    echo "hostname already ${name}, nothing to do"
    exit 0
fi

echo "setting hostname ${current} -> ${name} (source: ${source})"
hostnamectl set-hostname "$name"
