#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-openssl.sh — Configure SSL CA trust for OpenSSL / general TLS
#  Sets SSL_CERT_FILE and SSL_CERT_DIR
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

echo "==> OpenSSL / general TLS configured"
echo "    SSL_CERT_FILE=$SSL_CERT_FILE"
echo "    SSL_CERT_DIR=$SSL_CERT_DIR"
echo ""
echo "These variables are respected by most TLS stacks that"
echo "build on OpenSSL, LibreSSL, or BoringSSL."
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export SSL_CERT_FILE=\"$BUNDLE\""
echo "    export SSL_CERT_DIR=\"$CERTS_OUT\""
