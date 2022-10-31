Building:

docker build -t keycloak --build-arg GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID --build-arg GOOGLE_SECRET=YOUR_GOOGLE_CLIENT_SECRET --build-arg LDAP_URL=YOUR_LDAP_URL --build-arg USERSDN=YOUR_USER_DN .

Running:

docker run -p 8081:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin --rm --name=keycloack  keycloak



