#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-node.sh — Configure SSL CA trust for Node.js
#  Sets NODE_EXTRA_CA_CERTS to the ca-bundle.pem in ~/ssl
# ─────────────────────────────────────────────────────────────────

SSL_ROOT="$HOME/ssl"
BUNDLE="$SSL_ROOT/ca-bundle.pem"

if [[ ! -f "$BUNDLE" ]]; then
  echo "Error: CA bundle not found at $BUNDLE" >&2
  echo "Run install-certs.sh first to create it." >&2
  exit 1
fi

export NODE_EXTRA_CA_CERTS="$BUNDLE"

echo "==> Node.js SSL configured"
echo "    NODE_EXTRA_CA_CERTS=$NODE_EXTRA_CA_CERTS"
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export NODE_EXTRA_CA_CERTS=\"$BUNDLE\""
