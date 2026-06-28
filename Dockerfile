# pull the MySQL image
FROM mysql:8.0

# environment for MySQL
ENV MYSQL_ROOT_PASSWORD=demopass
ENV MYSQL_DATABASE=demodb

# Copy all local SQL scripts into the init directory
COPY ./init.sql/ /docker-entrypoint-initdb.d/

# expose the default MySQL port
EXPOSE 3307