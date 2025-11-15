FROM quay.io/keycloak/keycloak:19.0.3

WORKDIR /opt/keycloak
USER root

# environment variables
#ENV KC_DB
#ENV KC_DB_URL
#ENV KC_DB_USERNAME
#ENV RELATIVE_PATH
#ENV HOSTNAME
#ENV FEDERATE_LDAP
#ENV LDAP_URL
#ENV USERDN
#ENV GOOGLE_IDP
#ENV GOOGLE_CLIENT_ID
#ENV GOOGLE_SECRET
#ENV HTTP_ENABLED

# Install prerequisites using microdnf since in a Red Hat Universal Base Image (UBI) minimal image
#  - https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/assembly_adding-software-to-a-ubi-container_building-running-and-managing-containers
RUN microdnf install -y jq \
    && microdnf clean all

# Generate self-signed TLS keystore
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 \
    -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
    -keystore conf/server.keystore

# Copy realm files and start script
COPY realm_files/ realm_files/
COPY start.sh .
RUN chmod +x start.sh

# Build Keycloak with Postgres support
RUN /opt/keycloak/bin/kc.sh build --db=postgres

# Entrypoint
ENTRYPOINT ["/usr/bin/env"]
CMD ["/opt/keycloak/start.sh"]
