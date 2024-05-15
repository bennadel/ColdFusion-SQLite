FROM lucee/lucee:5.4.4.38

# Setup the password for the Lucee admin.
COPY ./docker/cfml/password.txt /opt/lucee/server/lucee-server/context/

# Setup the SQLite JDBC driver.
COPY ./docker/cfml/lib/sqlite-jdbc-3.45.3.0.jar /opt/lucee/server/lucee-server/context/lib
# Note: We didn't need to copy the SLF4J JAR because Lucee already has one.
# COPY ./docker/cfml/lib/slf4j-api-1.7.36.jar /opt/lucee/server/lucee-server/bundles
