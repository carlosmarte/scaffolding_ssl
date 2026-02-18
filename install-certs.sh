#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  install-certs.sh — Split a PEM bundle, inspect certs, rebuild
#  a clean CA bundle, and install into ~/ssl for macOS trust.
# ─────────────────────────────────────────────────────────────────

SSL_ROOT="$HOME/ssl"
CERTS_OUT="$SSL_ROOT/certs_out"
BUNDLE_OUT="$SSL_ROOT/ca-bundle.pem"

usage() {
  cat <<EOF
Usage: $(basename "$0") <bundle.pem>

  bundle.pem   Path to a PEM file containing one or more certificates.

The script will:
  1. Create ~/ssl/certs_out/
  2. Split the bundle into individual PEM files
  3. Inspect each certificate (subject, issuer, dates, fingerprint)
  4. Rebuild a clean ca-bundle.pem
  5. Optionally import certs into the macOS System keychain
  6. Print shell exports for Node.js, Python, pip, OpenSSL, Java, Go
EOF
  exit 1
}

# ── Argument check ───────────────────────────────────────────────
[[ $# -lt 1 ]] && usage
BUNDLE="$1"

if [[ ! -f "$BUNDLE" ]]; then
  echo "Error: file not found: $BUNDLE" >&2
  exit 1
fi

# ── Create directory structure ───────────────────────────────────
echo "==> Creating SSL root at $SSL_ROOT"
mkdir -p "$CERTS_OUT"

# ── Split the bundle into individual certs ───────────────────────
echo "==> Splitting bundle into individual certificates..."

# csplit portability: macOS csplit uses slightly different flags
# than GNU csplit. The invocation below works on macOS (BSD csplit).
csplit -f "$CERTS_OUT/cert-" -b "%04d.pem" -n 4 -s "$BUNDLE" \
  '/-----BEGIN CERTIFICATE-----/' '{*}' 2>/dev/null || true

# Remove any empty fragments (first split chunk is often empty)
find "$CERTS_OUT" -type f -size 0 -delete

CERT_COUNT=$(find "$CERTS_OUT" -name '*.pem' | wc -l | tr -d ' ')
if [[ "$CERT_COUNT" -eq 0 ]]; then
  echo "Error: no certificates found in $BUNDLE" >&2
  exit 1
fi
echo "    Found $CERT_COUNT certificate(s)"

# ── Inspect each certificate ────────────────────────────────────
echo ""
echo "==> Certificate details:"
echo "────────────────────────────────────────────────────────────"
for f in "$CERTS_OUT"/*.pem; do
  echo ""
  echo "== $(basename "$f") =="
  openssl x509 -in "$f" -noout \
    -subject -issuer -dates -fingerprint -sha256 2>/dev/null || {
    echo "    (not a valid X.509 certificate — skipping)"
    rm -f "$f"
  }
done
echo ""
echo "────────────────────────────────────────────────────────────"

# Recount after removing invalid certs
CERT_COUNT=$(find "$CERTS_OUT" -name '*.pem' | wc -l | tr -d ' ')

# ── Rebuild clean bundle ────────────────────────────────────────
echo ""
echo "==> Rebuilding clean CA bundle at $BUNDLE_OUT"
cat "$CERTS_OUT"/cert-*.pem > "$BUNDLE_OUT"
echo "    Bundle contains $CERT_COUNT certificate(s)"

# ── macOS Keychain import ────────────────────────────────────────
echo ""
echo "==> macOS Keychain import"
echo "    The following will add each cert to the System keychain."
echo "    This requires administrator (sudo) privileges."
echo ""
read -rp "    Import into macOS System keychain? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  for f in "$CERTS_OUT"/*.pem; do
    SUBJ=$(openssl x509 -in "$f" -noout -subject 2>/dev/null | sed 's/^subject=//')
    echo "    Importing: $SUBJ"
    sudo security add-trusted-cert \
      -d \
      -r trustRoot \
      -k /Library/Keychains/System.keychain \
      "$f"
  done
  echo "    Done. Certificates are now trusted system-wide."
else
  echo "    Skipped keychain import."
  echo "    You can import manually later with:"
  echo "      sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain <cert.pem>"
fi
