FROM quay.io/keycloak/keycloak:19.0.3
ARG LDAP_URL
ENV LDAP_URL_Arg=$LDAP_URL
ARG USERSDN
ENV USERSDN_Arg=$USERSDN
ARG GOOGLE_CLIENT_ID
ENV GOOGLE_CLIENT_ID_Arg=$GOOGLE_CLIENT_ID
ARG GOOGLE_SECRET
ENV GOOGLE_SECRET_Arg=$GOOGLE_SECRET
ADD ssm.json /opt/keycloak/data/import/ssm.json
USER root
RUN sed -i 's/LDAP_URL_REPLACEMENT/${LDAP_URL_Arg}/g' /opt/keycloak/data/import/ssm.json
RUN sed -i 's/USERSDN_REPLACEMENT/${USERSDN_Arg}/g' /opt/keycloak/data/import/ssm.json
RUN sed -i 's/GOOGLE_CLIENT_ID_REPLACEMENT/${GOOGLE_CLIENT_Arg}/g' /opt/keycloak/data/import/ssm.json
RUN sed -i 's/GOOGLE_CLIENT_SECRET_REPLACEMENT/${GOOGLE_SECRET_Arg}/g' /opt/keycloak/data/import/ssm.json
USER keycloak
#ADD ssm-users-0.json /opt/keycloak/data/import/ssm-users-0.json
#ADD messages_en.properties /opt/keycloak/themes/ssm/login/messages/messages_en.properties
CMD [ "start-dev", "--import-realm" ]
