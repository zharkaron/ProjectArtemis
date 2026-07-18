#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
CERTS_DIR="$SCRIPT_DIR/certs"
PASSWORD_FILE="$CONFIG_DIR/password.txt"
CA_URL="https://step-ca:9000"
STEP_IMAGE="smallstep/step-cli:0.27.5"
CA_IMAGE="smallstep/step-ca:0.27.5"
CA_NAME="ProjectArtemis Root CA"
CA_DNS="step-ca"
CA_ADDRESS=":9000"
CA_PROVISIONER="admin"

mkdir -p "$CONFIG_DIR" "$CERTS_DIR"

if [ -f "$CONFIG_DIR/ca.json" ]; then
    echo "CA already initialized at $CONFIG_DIR/ca.json"
    echo "Delete $CONFIG_DIR and $CERTS_DIR to re-initialize."
    exit 1
fi

echo "==> Generating CA password..."
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32 > "$PASSWORD_FILE"
echo "Password saved to $PASSWORD_FILE"

echo "==> Initializing step-ca..."
docker run --rm -i \
    -v "$CONFIG_DIR:/home/step/config" \
    -v "$CERTS_DIR:/home/step/certs" \
    -v "$PASSWORD_FILE:/home/step/secrets/password.txt" \
    "$STEP_IMAGE" step ca init \
    --name "$CA_NAME" \
    --dns "$CA_DNS" \
    --address "$CA_ADDRESS" \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password.txt \
    --provisioner-password-file /home/step/secrets/password.txt

echo "==> Adding ACME provisioner for Caddy..."
docker run --rm -i \
    -v "$CONFIG_DIR:/home/step/config" \
    -v "$CERTS_DIR:/home/step/certs" \
    -v "$PASSWORD_FILE:/home/step/secrets/password.txt" \
    "$STEP_IMAGE" step ca provisioner add acme \
    --type ACME \
    --challenge-types http-01 \
    --password-file /home/step/secrets/password.txt

echo "==> Starting step-ca temporarily to generate device certs..."
CA_CONTAINER="step-ca-init-temp"
docker run --rm -d --name "$CA_CONTAINER" \
    --network projectartemis_internal \
    -v "$CONFIG_DIR:/home/step/config:ro" \
    -v "$CERTS_DIR:/home/step/certs" \
    -v "$PASSWORD_FILE:/home/step/secrets/password.txt:ro" \
    -p 127.0.0.1:9000:9000 \
    "$CA_IMAGE"

echo "==> Waiting for step-ca to be ready..."
for i in $(seq 1 30); do
    if docker exec "$CA_CONTAINER" step ca health --ca-url "https://localhost:9000" --root /home/step/certs/root_ca.crt 2>/dev/null; then
        echo "step-ca is ready."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: step-ca did not start in time."
        docker logs "$CA_CONTAINER"
        docker stop "$CA_CONTAINER"
        exit 1
    fi
    sleep 1
done

echo "==> Generating device certificate: omen..."
docker exec "$CA_CONTAINER" step ca certificate \
    "omen.zharkaron.lab" \
    /home/step/certs/omen.crt \
    /home/step/certs/omen.key \
    --ca-url "https://localhost:9000" \
    --root /home/step/certs/root_ca.crt \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password.txt \
    --not-after 87600h --not-after 87600h

echo "==> Generating device certificate: iphone..."
docker exec "$CA_CONTAINER" step ca certificate \
    "iphone.zharkaron.lab" \
    /home/step/certs/iphone.crt \
    /home/step/certs/iphone.key \
    --ca-url "https://localhost:9000" \
    --root /home/step/certs/root_ca.crt \
    --provisioner "$CA_PROVISIONER" \
    --password-file /home/step/secrets/password.txt \
    --not-after 87600h --not-after 87600h

echo "==> Stopping temporary step-ca..."
docker stop "$CA_CONTAINER"

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
echo "  1. docker compose up -d step-ca caddy"
echo "  2. Install root_ca.crt on your devices (one-time)"
echo "  3. Connect to WireGuard VPN"
echo "  4. Access https://*.zharkaron.lab — trusted by default!"
