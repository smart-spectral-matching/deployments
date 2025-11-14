#!/usr/bin/env bash
set -euo pipefail

# Get the directory this script lives in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Absolute paths
SSM_FILE="${SCRIPT_DIR}/realm_files/ssm.json"
LDAP_TEMPLATE_JSON="${SCRIPT_DIR}/realm_files/ldap-template.json"
GOOGLE_TEMPLATE_JSON="${SCRIPT_DIR}/realm_files/google-template.json"
TMP_FILE="$(mktemp)"

# Load environment variables
: "${FEDERATE_LDAP:=}"
: "${LDAP_URL:=}"
: "${USERSDN:=}"
: "${GOOGLE_IDP:=}"
: "${GOOGLE_CLIENT_ID:=}"
: "${GOOGLE_SECRET:=}"
: "${DEV_MODE:=false}"

# Function to patch LDAP block
patch_ldap() {
  jq --arg ldapUrl "${LDAP_URL}" \
     --arg usersDn "${USERSDN}" \
     --slurpfile ldapTpl "${LDAP_TEMPLATE_JSON}" \
     '.["org.keycloak.storage.UserStorageProvider"] = [
         ($ldapTpl[0] |
           .config.usersDn = [$usersDn] |
           .config.connectionUrl = [$ldapUrl])
       ]' \
     "${SSM_FILE}" > "${TMP_FILE}"
  mv "${TMP_FILE}" "${SSM_FILE}"
  echo "→ Patched LDAP configuration"
}

# Function to patch Google IdP block
patch_google() {
  jq --arg clientId "${GOOGLE_CLIENT_ID}" \
     --arg secret "${GOOGLE_SECRET}" \
     --slurpfile googleTpl "${GOOGLE_TEMPLATE_JSON}" \
     '.["identityProviders"] = [
         ($googleTpl[0] |
           .config.clientId = $clientId |
           .config.clientSecret = $secret)
       ]' \
     "${SSM_FILE}" > "${TMP_FILE}"
  mv "${TMP_FILE}" "${SSM_FILE}"
  echo "→ Patched Google IdP configuration"
}

# Main logic
if [[ -n "${FEDERATE_LDAP}" ]]; then
  patch_ldap
fi

if [[ -n "${GOOGLE_IDP}" ]]; then
  patch_google
fi

echo "✔ ssm.json updated successfully"

# Import realms JSON
/opt/keycloak/bin/kc.sh import --file "${SSM_FILE}" --override true

# Decide on Keycloak start command (dev-mode or normal)
cmd="start"
[[ "${DEV_MODE,,}" == "true" ]] && cmd="start-dev"

# Start server
exec /opt/keycloak/bin/kc.sh "$cmd" \
  --db "${KC_DB}" \
  --db-url "${KC_DB_URL}" \
  --db-username "${KC_DB_USERNAME}" \
  --db-password "${KC_DB_PASSWORD}" \
  --hostname "${HOSTNAME}" \
  --http-relative-path "${RELATIVE_PATH}" \
  --http-enabled="${HTTP_ENABLED}" \
  --https-key-store-file=conf/server.keystore
