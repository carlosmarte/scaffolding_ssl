#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────
#  ssl-java.sh — Configure SSL CA trust for Java
#  Creates a PKCS12 truststore from certs in ~/ssl/certs_out
#  and sets JAVA_TOOL_OPTIONS for the JVM.
# ─────────────────────────────────────────────────────────────────

SSL_ROOT="$HOME/ssl"
CERTS_OUT="$SSL_ROOT/certs_out"
TRUSTSTORE="$SSL_ROOT/truststore.p12"
STOREPASS="changeit"

if [[ ! -d "$CERTS_OUT" ]]; then
  echo "Error: certs directory not found at $CERTS_OUT" >&2
  echo "Run install-certs.sh first to create it." >&2
  exit 1
fi

CERT_COUNT=$(find "$CERTS_OUT" -name '*.pem' | wc -l | tr -d ' ')
if [[ "$CERT_COUNT" -eq 0 ]]; then
  echo "Error: no PEM files found in $CERTS_OUT" >&2
  exit 1
fi

echo "==> Building Java PKCS12 truststore at $TRUSTSTORE"
echo "    Found $CERT_COUNT certificate(s) to import"
echo ""

# Remove existing truststore to start clean
[[ -f "$TRUSTSTORE" ]] && rm -f "$TRUSTSTORE"

INDEX=0
for f in "$CERTS_OUT"/*.pem; do
  ALIAS="ca-${INDEX}"
  SUBJ=$(openssl x509 -in "$f" -noout -subject 2>/dev/null | sed 's/^subject=//' || echo "unknown")
  echo "    [$ALIAS] $SUBJ"
  keytool -importcert -noprompt \
    -alias "$ALIAS" \
    -file "$f" \
    -keystore "$TRUSTSTORE" \
    -storetype PKCS12 \
    -storepass "$STOREPASS" 2>/dev/null
  INDEX=$((INDEX + 1))
done

export JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=$TRUSTSTORE -Djavax.net.ssl.trustStorePassword=$STOREPASS"

echo ""
echo "==> Java SSL configured"
echo "    Truststore: $TRUSTSTORE"
echo "    JAVA_TOOL_OPTIONS=$JAVA_TOOL_OPTIONS"
echo ""
echo "To make this permanent, add to your shell profile (~/.zshrc):"
echo ""
echo "    export JAVA_TOOL_OPTIONS=\"-Djavax.net.ssl.trustStore=$TRUSTSTORE -Djavax.net.ssl.trustStorePassword=$STOREPASS\""
