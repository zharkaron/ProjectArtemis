#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
CERTS_DIR="$SCRIPT_DIR/certs"
SECRETS_DIR="$SCRIPT_DIR/secrets"
DB_DIR="$SCRIPT_DIR/db"
PASSWORD_FILE="$SECRETS_DIR/password"
STEP_IMAGE="smallstep/step-cli:0.27.5"
CA_IMAGE="smallstep/step-ca:0.27.5"
CA_NAME="ProjectArtemis Root CA"
CA_DNS="step-ca"
CA_ADDRESS=":9000"
CA_PROVISIONER="admin"

mkdir -p "$CONFIG_DIR" "$CERTS_DIR" "$SECRETS_DIR" "$DB_DIR"

if [ -f "$SECRETS_DIR/root_ca_key" ]; then
    echo "CA already initialized."
    echo "Delete $SECRETS_DIR, $CERTS_DIR, $CONFIG_DIR/ca.json, $CONFIG_DIR/defaults.json, and $DB_DIR to re-initialize."
    exit 1
fi

echo "==> Generating CA password..."
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32 > "$PASSWORD_FILE"
chown 1000:1000 "$PASSWORD_FILE"
chmod 644 "$PASSWORD_FILE"
echo "Password saved to $PASSWORD_FILE"

echo "==> Initializing step-ca..."
docker run --rm -i --user root \
    -v "$CONFIG_DIR:/home/step/config:z" \
    -v "$CERTS_DIR:/home/step/certs:z" \
    -v "$SECRETS_DIR:/home/step/secrets:z" \
    "$STEP_IMAGE" step ca init \
    --name "$CA_NAME" \
    --dns "$CA_DNS" \
    --address "$CA_ADDRESS" \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password \
    --provisioner-password-file /home/step/secrets/password

echo "==> Fixing ownership..."
chown -R 1000:1000 "$CONFIG_DIR" "$CERTS_DIR" "$SECRETS_DIR" "$DB_DIR"
chmod 600 "$SECRETS_DIR"/*.key 2>/dev/null || true

echo "==> Adding ACME provisioner for Caddy..."
docker run --rm -i --user root \
    -v "$CONFIG_DIR:/home/step/config:z" \
    -v "$CERTS_DIR:/home/step/certs:z" \
    -v "$SECRETS_DIR:/home/step/secrets:z" \
    "$STEP_IMAGE" step ca provisioner add acme \
    --type ACME \
    --challenge http-01 \
    --ca-config /home/step/config/ca.json

echo "==> Updating CA claims for long-lived device certs..."
docker run --rm -i --user root \
    -v "$CONFIG_DIR:/home/step/config:z" \
    "$STEP_IMAGE" sh -c '
        apk add --no-cache python3 >/dev/null 2>&1
        python3 -c "
import json
with open(\"/home/step/config/ca.json\") as f:
    cfg = json.load(f)
cfg[\"authority\"][\"claims\"] = {
    \"maxTLSCertDuration\": \"87600h\",
    \"defaultTLSCertDuration\": \"8760h\",
    \"minTLSCertDuration\": \"5m\"
}
with open(\"/home/step/config/ca.json\", \"w\") as f:
    json.dump(cfg, f, indent=2)
print(\"Updated ca.json with cert duration claims\")
"
    '

echo "==> Starting step-ca temporarily..."
docker run --rm -d --name step-ca-init-temp \
    --network projectartemis_internal \
    --dns 172.22.0.53 \
    -v "$CONFIG_DIR:/home/step/config:z" \
    -v "$CERTS_DIR:/home/step/certs:z" \
    -v "$SECRETS_DIR:/home/step/secrets:z" \
    -v "$DB_DIR:/home/step/db:z" \
    "$CA_IMAGE"

echo "==> Waiting for step-ca to be ready..."
for i in $(seq 1 30); do
    if docker logs step-ca-init-temp 2>&1 | grep -q "Serving HTTPS"; then
        echo "step-ca is ready."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: step-ca did not start in time."
        docker logs step-ca-init-temp
        docker stop step-ca-init-temp
        exit 1
    fi
    sleep 1
done

echo "==> Generating device certificate: omen..."
docker run --rm -i \
    --network projectartemis_internal \
    --dns 172.22.0.53 \
    -v "$CERTS_DIR:/home/step/certs:z" \
    -v "$SECRETS_DIR:/home/step/secrets:z" \
    "$STEP_IMAGE" step ca certificate \
    "omen.zharkaron.lab" \
    /home/step/certs/omen.crt \
    /home/step/certs/omen.key \
    --ca-url https://step-ca:9000 \
    --root /home/step/certs/root_ca.crt \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password \
    --not-after 87600h

echo "==> Generating device certificate: iphone..."
docker run --rm -i \
    --network projectartemis_internal \
    --dns 172.22.0.53 \
    -v "$CERTS_DIR:/home/step/certs:z" \
    -v "$SECRETS_DIR:/home/step/secrets:z" \
    "$STEP_IMAGE" step ca certificate \
    "iphone.zharkaron.lab" \
    /home/step/certs/iphone.crt \
    /home/step/certs/iphone.key \
    --ca-url https://step-ca:9000 \
    --root /home/step/certs/root_ca.crt \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password \
    --not-after 87600h

echo "==> Stopping temporary step-ca..."
docker stop step-ca-init-temp

echo "==> Fixing ownership..."
chown -R 1000:1000 "$CONFIG_DIR" "$CERTS_DIR" "$SECRETS_DIR" "$DB_DIR"

echo ""
echo "========================================="
echo "  step-ca initialized successfully!"
echo "========================================="
echo ""
echo "Root CA cert:  $CERTS_DIR/root_ca.crt"
echo "CA password:   $PASSWORD_FILE"
echo ""
echo "Device certificates:"
echo "  omen:   $CERTS_DIR/omen.crt / $CERTS_DIR/omen.key"
echo "  iphone: $CERTS_DIR/iphone.crt / $CERTS_DIR/iphone.key"
echo ""
echo "Next steps:"
echo "  1. docker compose up -d"
echo "  2. Install root_ca.crt on your devices (one-time)"
echo "  3. Connect to WireGuard VPN"
echo "  4. Access https://*.zharkaron.lab -- trusted by default!"
