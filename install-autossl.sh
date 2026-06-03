#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root: sudo ./install-autossl.sh"
  exit 1
fi

INSTALL_PATH="/usr/local/bin/autossl"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/autossl" ]; then
  echo "autossl file not found in current directory."
  exit 1
fi

install -m 755 "$SCRIPT_DIR/autossl" "$INSTALL_PATH"
mkdir -p /etc/autossl /etc/ssl/acme
chmod 700 /etc/autossl /etc/ssl/acme

echo "AutoSSL installed to $INSTALL_PATH"
echo
echo "Next step:"
echo "  sudo autossl setup"
echo
echo "Then use:"
echo "  autossl check -d domain.com"
echo "  autossl issue -d domain.com"
