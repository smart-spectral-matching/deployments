FROM quay.io/keycloak/keycloak:19.0.3

WORKDIR /opt/keycloak
USER root

# Replace this with real TLS certificates
#ADD clientkeystore conf/server.keystore
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build --db=postgres

ADD ssm.json /ssm.json
ADD start.sh .
RUN chmod 777 start.sh

ENTRYPOINT [ "/usr/bin/env" ]
CMD [ "/opt/keycloak/start.sh" ]
