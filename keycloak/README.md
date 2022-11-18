Running:

docker-compose up

Configuring:

Remove FEDERATE_LDAP to turn off user federation. LDAP_URL and USERDN must be configured for federation.

Remove GOOGLE_IDP to prevent users from loggin in with Google accounts. GOOGLE_CLIENT_ID and GOOGLE_SECRET must be set for Google authentication.

To configure as a production server, uncomment HTTPS and set HOSTNAME correctly.



