#!/usr/bin/env bash
set -euo pipefail

# Generate a patched `ssm.json` to stdout without modifying repo files.
# Respects the same env vars used by `start.sh`: FEDERATE_LDAP, LDAP_URL, USERSDN,
# GOOGLE_IDP, GOOGLE_CLIENT_ID, GOOGLE_SECRET.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSM_SRC="${SCRIPT_DIR}/../realm_files/ssm.json"
LDAP_TEMPLATE_JSON="${SCRIPT_DIR}/../realm_files/ldap-template.json"
GOOGLE_TEMPLATE_JSON="${SCRIPT_DIR}/../realm_files/google-template.json"

: "${FEDERATE_LDAP:=}"
: "${LDAP_URL:=}"
: "${USERSDN:=}"
: "${GOOGLE_IDP:=}"
: "${GOOGLE_CLIENT_ID:=}"
: "${GOOGLE_SECRET:=}"

TMPFILE="$(mktemp)"
cp "$SSM_SRC" "$TMPFILE"

if [[ -n "${FEDERATE_LDAP:-}" ]]; then
  jq --arg ldapUrl "$LDAP_URL" \
     --arg usersDn "$USERSDN" \
     --slurpfile ldapTpl "$LDAP_TEMPLATE_JSON" \
     '.components = [
         ($ldapTpl[0] |
           .config.usersDn = [$usersDn] |
           .config.connectionUrl = [$ldapUrl])
     ]' "$TMPFILE" > "${TMPFILE}.new"
  mv "${TMPFILE}.new" "$TMPFILE"
fi

if [[ -n "${GOOGLE_IDP:-}" ]]; then
  jq --arg clientId "$GOOGLE_CLIENT_ID" \
     --arg secret "$GOOGLE_SECRET" \
     --slurpfile googleTpl "$GOOGLE_TEMPLATE_JSON" \
     '.identityProviders = [
         ($googleTpl[0] |
           .config.clientId = $clientId |
           .config.clientSecret = $secret)
     ]' "$TMPFILE" > "${TMPFILE}.new"
  mv "${TMPFILE}.new" "$TMPFILE"
fi

cat "$TMPFILE"
rm -f "$TMPFILE"
