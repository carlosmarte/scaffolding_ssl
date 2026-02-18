#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-python.sh — Configure SSL CA trust for Python
#  Sets REQUESTS_CA_BUNDLE, SSL_CERT_FILE, and PIP_CERT
# ─────────────────────────────────────────────────────────────────

SSL_ROOT="$HOME/ssl"
BUNDLE="$SSL_ROOT/ca-bundle.pem"

if [[ ! -f "$BUNDLE" ]]; then
  echo "Error: CA bundle not found at $BUNDLE" >&2
  echo "Run install-certs.sh first to create it." >&2
  exit 1
fi

export REQUESTS_CA_BUNDLE="$BUNDLE"
export SSL_CERT_FILE="$BUNDLE"
export PIP_CERT="$BUNDLE"

echo "==> Python SSL configured"
echo "    REQUESTS_CA_BUNDLE=$REQUESTS_CA_BUNDLE"
echo "    SSL_CERT_FILE=$SSL_CERT_FILE"
echo "    PIP_CERT=$PIP_CERT"
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export REQUESTS_CA_BUNDLE=\"$BUNDLE\""
echo "    export SSL_CERT_FILE=\"$BUNDLE\""
echo "    export PIP_CERT=\"$BUNDLE\""
echo ""
echo "To make pip config permanent (alternative to PIP_CERT):"
echo "    pip config set global.cert \"$BUNDLE\""
