# Use Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variables for MySQL
ENV MYSQL_VERSION=5.7.44
ENV MYSQL_TAR_URL=https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz
ENV MYSQL_ROOT_PASSWORD=welcome@123

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y wget libaio1 libnuma1 libncurses5 && \
    apt-get clean

# Create a directory for MySQL and download MySQL tarball
RUN mkdir -p /usr/local/mysql && \
    wget $MYSQL_TAR_URL -O /tmp/mysql.tar.gz && \
    tar -xzf /tmp/mysql.tar.gz -C /usr/local/mysql --strip-components=1 && \
    rm /tmp/mysql.tar.gz

# Set up MySQL user and permissions
RUN groupadd mysql && useradd -r -g mysql mysql && \
    mkdir -p /var/lib/mysql && chown -R mysql:mysql /usr/local/mysql /var/lib/mysql

# Create MySQL configuration file
RUN echo "[mysqld]\n\
bind-address = 0.0.0.0\n\
port = 3306" > /etc/my.cnf

# Add MySQL binaries to PATH
ENV PATH="/usr/local/mysql/bin:${PATH}"

# Initialize MySQL data directory (insecure mode)
RUN /usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

# Start MySQL, set the root password, grant privileges, and shut down MySQL
RUN /usr/local/mysql/bin/mysqld --user=mysql --skip-networking --datadir=/var/lib/mysql & \
    sleep 10 && \
    /usr/local/mysql/bin/mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" && \
    /usr/local/mysql/bin/mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" && \
    /usr/local/mysql/bin/mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" && \
    /usr/local/mysql/bin/mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Expose MySQL port
EXPOSE 3306

# Set entrypoint to MySQL server
ENTRYPOINT ["/usr/local/mysql/bin/mysqld"]

# Default command to run MySQL
CMD ["--user=mysql", "--datadir=/var/lib/mysql"]
