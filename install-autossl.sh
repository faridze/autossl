#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root: sudo ./install-autossl.sh"
  exit 1
fi

INSTALL_PATH="/usr/local/bin/autossl"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="/etc/autossl/backups"

if [ ! -f "$SCRIPT_DIR/autossl" ]; then
  echo "autossl file not found in current directory."
  exit 1
fi

mkdir -p /etc/autossl /etc/ssl/acme "$BACKUP_DIR"
chmod 700 /etc/autossl /etc/ssl/acme "$BACKUP_DIR"

if [ -f "$INSTALL_PATH" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP_PATH="$BACKUP_DIR/autossl.$TS.bak"
  while [ -e "$BACKUP_PATH" ]; do
    BACKUP_PATH="$BACKUP_DIR/autossl.$TS.$RANDOM.bak"
  done
  cp -a "$INSTALL_PATH" "$BACKUP_PATH"
  echo "Previous AutoSSL saved to $BACKUP_PATH"
fi

install -m 755 "$SCRIPT_DIR/autossl" "$INSTALL_PATH"

echo "AutoSSL installed to $INSTALL_PATH"
echo "Installed version: $($INSTALL_PATH version 2>/dev/null || true)"
echo
echo "Next step:"
echo "  sudo autossl setup"
echo
echo "Then use:"
echo "  autossl doctor"
echo "  autossl check -d domain.com"
echo "  autossl issue -d domain.com --staging"
