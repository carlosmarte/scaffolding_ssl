#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-go.sh — Configure SSL CA trust for Go
#  Sets SSL_CERT_FILE and SSL_CERT_DIR for crypto/x509
# ─────────────────────────────────────────────────────────────────

SSL_ROOT="$HOME/ssl"
BUNDLE="$SSL_ROOT/ca-bundle.pem"
CERTS_OUT="$SSL_ROOT/certs_out"

if [[ ! -f "$BUNDLE" ]]; then
  echo "Error: CA bundle not found at $BUNDLE" >&2
  echo "Run install-certs.sh first to create it." >&2
  exit 1
fi

export SSL_CERT_FILE="$BUNDLE"
export SSL_CERT_DIR="$CERTS_OUT"

echo "==> Go SSL configured"
echo "    SSL_CERT_FILE=$SSL_CERT_FILE"
echo "    SSL_CERT_DIR=$SSL_CERT_DIR"
echo ""
echo "Note: If your CA is also imported into the macOS System"
echo "keychain (via install-certs.sh), Go's crypto/x509 will"
echo "pick it up automatically from system roots."
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export SSL_CERT_FILE=\"$BUNDLE\""
echo "    export SSL_CERT_DIR=\"$CERTS_OUT\""
