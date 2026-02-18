#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-rust.sh — Configure SSL CA trust for Rust
#  Sets SSL_CERT_FILE and SSL_CERT_DIR for native-tls / OpenSSL.
#
#  Backend notes:
#    reqwest + native-tls  → uses OS/OpenSSL; these env vars apply
#    reqwest + rustls      → ignores env vars; load certs in code
#                            or use rustls-native-certs crate
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

echo "==> Rust SSL configured (native-tls / OpenSSL backend)"
echo "    SSL_CERT_FILE=$SSL_CERT_FILE"
echo "    SSL_CERT_DIR=$SSL_CERT_DIR"
echo ""
echo "If using reqwest + rustls, these env vars are ignored."
echo "Instead, either:"
echo "  1. Add rustls-native-certs to Cargo.toml (loads OS roots)"
echo "  2. Load the PEM programmatically into the root store"
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export SSL_CERT_FILE=\"$BUNDLE\""
echo "    export SSL_CERT_DIR=\"$CERTS_OUT\""
