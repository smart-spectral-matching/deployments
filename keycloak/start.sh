#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# Directories & files
# ---------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSM_FILE="${SCRIPT_DIR}/realm_files/ssm.json"
LDAP_TEMPLATE_JSON="${SCRIPT_DIR}/realm_files/ldap-template.json"
GOOGLE_TEMPLATE_JSON="${SCRIPT_DIR}/realm_files/google-template.json"
TMP_FILE="$(mktemp)"

# ---------------------------
# Environment variables
# ---------------------------
: "${FEDERATE_LDAP:=}"
: "${LDAP_URL:=}"
: "${USERSDN:=}"
: "${GOOGLE_IDP:=}"
: "${GOOGLE_CLIENT_ID:=}"
: "${GOOGLE_SECRET:=}"
: "${DEV_MODE:=false}"
: "${KC_DB:=postgres}"
: "${KC_DB_URL:=jdbc:postgresql://ssm-postgres:5432/postgres}"
: "${KC_DB_USERNAME:=postgres}"
: "${KC_DB_PASSWORD:=postgres}"
: "${HOSTNAME:=localhost}"
: "${RELATIVE_PATH:=}"
: "${HTTP_ENABLED:=true}"

# ---------------------------
# Generate combined ssm.json from templates (if any) then write it
# to the repository path expected by the import step. We use the
# helper `scripts/generate_ssm.sh` so CI can reproduce the same
# output without starting Keycloak.
# ---------------------------
echo "→ Generating patched ssm.json from templates (if any)..."
"${SCRIPT_DIR}/scripts/generate_ssm.sh" > "$SSM_FILE"
echo "✔ ssm.json generated"

# ---------------------------
# Import realms
# ---------------------------
echo "→ Validating realm JSON..."
if ! jq empty "$SSM_FILE" >/dev/null 2>&1; then
    echo "ERROR: $SSM_FILE contains invalid JSON. Aborting import." >&2
    exit 1
fi

echo "→ Importing realm configuration..."
/opt/keycloak/bin/kc.sh import --file "$SSM_FILE" --override true

# ---------------------------
# Start Keycloak
# ---------------------------
cmd="start"
[[ "${DEV_MODE,,}" == "true" ]] && cmd="start-dev"

exec /opt/keycloak/bin/kc.sh "$cmd" \
    --db "${KC_DB}" \
    --db-url "${KC_DB_URL}" \
    --db-username "${KC_DB_USERNAME}" \
    --db-password "${KC_DB_PASSWORD}" \
    --hostname "${HOSTNAME}" \
    --http-relative-path "${RELATIVE_PATH}" \
    --http-enabled="${HTTP_ENABLED}"
