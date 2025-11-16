# Copilot / AI assistant instructions for this repo

This repository contains a small Keycloak deployment used by the SSM project. The goal of these instructions is to help AI coding agents be immediately productive: understand architecture, common workflows, and project-specific patterns.

**Big Picture**
- **What:** A self-contained Keycloak deployment (Dockerfile + `docker-compose.yml`) that builds a Keycloak image, imports a realm configuration (`realm_files/ssm.json`), and can optionally enable LDAP federation and Google IdP.
- **Components:** `keycloak` service (built from `Dockerfile`) and `postgres` service (`ssm-postgres`) defined in `docker-compose.yml`.
- **Data flow:** `start.sh` patches `realm_files/ssm.json` (using templates in `realm_files/*-template.json`) then runs `kc.sh import` to load the realm into Keycloak backed by Postgres.

**Files to inspect first**
- `Dockerfile` — builds Keycloak image, installs `jq`, generates a self-signed keystore, copies `realm_files/` and `start.sh`, and runs `kc.sh build --db=postgres`.
- `start.sh` — the runtime entry script. It:
  - Reads environment variables and applies patches to `realm_files/ssm.json` with `jq`.
  - Template files: `realm_files/ldap-template.json`, `realm_files/google-template.json`.
  - Imports the patched realm via `/opt/keycloak/bin/kc.sh import`.
  - Starts Keycloak with either `start` or `start-dev` based on `DEV_MODE`.
- `realm_files/` — holds `ssm.json` (main realm) and template fragments for LDAP/Google. Changes here are applied by `start.sh` before import.
- `docker-compose.yml` — shows exposed port mapping (`8081:8080`) and default env values used during local runs.

**Important environment variables (defined or referenced in `start.sh`)**
- `FEDERATE_LDAP` — if set (non-empty), `start.sh` patches LDAP config from `ldap-template.json`. Also set `LDAP_URL` and `USERSDN`.
- `GOOGLE_IDP`, `GOOGLE_CLIENT_ID`, `GOOGLE_SECRET` — toggle and configure Google identity provider.
- `KC_DB`, `KC_DB_URL`, `KC_DB_USERNAME`, `KC_DB_PASSWORD` — database configuration (defaults assume the `ssm-postgres` service).
- `HOSTNAME`, `RELATIVE_PATH`, `HTTP_ENABLED`, `DEV_MODE` — Keycloak runtime flags passed to `kc.sh`.

**Common workflows & commands**
- Development run (local compose):
```bash
docker-compose up --build
```
- Rebuild the Keycloak image (when changing Dockerfile or realm files copied at build time):
```bash
docker build -t local/keycloak .
docker-compose up --build
```
- Importing/debugging realm manually inside container:
```bash
docker-compose run --rm keycloak /bin/bash
# then inside container:
/opt/keycloak/bin/kc.sh import --file /opt/keycloak/realm_files/ssm.json --override true
```
- Follow logs:
```bash
docker-compose logs -f keycloak
```

**Patterns & conventions to follow when editing**
- Realm changes should be made in `realm_files/ssm.json` or in template files (`*-template.json`) used by `start.sh`.
- If you add new realm templates, update `start.sh` to include the patch logic (follow existing `patch_ldap` / `patch_google` examples).
- Avoid editing the `kc.sh build` step unless you know you need a different DB provider — the image is prebuilt for Postgres in `Dockerfile`.
- The `ENTRYPOINT`/`CMD` combination in the `Dockerfile` uses `/usr/bin/env` then `start.sh` — prefer invoking `kc.sh` or `start.sh` directly in debugging sessions.

**Debug hints & pitfalls**
- `start.sh` uses `jq` and `mktemp`; ensure any edits preserve JSON shape expected by Keycloak. Use `jq . realm_files/ssm.json` to validate.
- The Dockerfile generates a self-signed keystore at `conf/server.keystore` — HTTPS is disabled/commented in `docker-compose.yml` by default.
- Port mapping is `8081:8080`. If Keycloak appears unreachable, check `HOSTNAME`, `HTTP_ENABLED`, and `--http-relative-path` settings.
- When enabling LDAP federation, ensure `LDAP_URL` is reachable from the container (ldaps will require cert/trust if using LDAPS).

**Where to look for tests / CI / further docs**
- This repo does not include automated tests or CI configs. The main documentation is `README.md` at the repo root (contains quickstart and env hints).

If anything here is unclear or you'd like me to add examples (e.g., sample `docker-compose` overrides, a healthcheck, or a small test harness for imports), tell me which piece to expand and I will iterate.
