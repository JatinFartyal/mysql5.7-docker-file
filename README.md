# mysql5.7-docker-file

This takes ubuntu 20.04 base image in installing mysql5.7.44 in it from archives

Steps:
1. Create volume for persistence data:</br>
  ```docker volume create mysql-data```

2. Navigate to the directory with dockerfile to build image</br>
  ```docker build --platform linux/amd64 -t ubuntu-mysql-5.7.44 .```

3. Run container:</br>
```
  docker run -d \
    --name mysql5.7.44 \
    -p 127.0.0.1:3307:3306 \
    -e MYSQL_ROOT_PASSWORD=welcome@123 \
    -v mysql-data:/path/to/local/storage/on/host \
    ubuntu-mysql-5.7.44
```

4. Copy the sql file inside container:</br>
  ```docker cp /path/to/mysql.sql mysql5.7.44:/tmp/mysql.sql```

5. Enter the container:</br>
  ```docker exec -it mysql5.7.44 bash```</br>

6. enter mysql shell and create your database</br>
  ```mysql -u root -pwelcome@123```</br>
  ```CREATE DATABASE mydatabase;```</br>
  ```exit```</br>

7. import the database and exit the container</br>
  ```mysql -u root -p mydatabase < /tmp/mysql.sql```</br>
  ```exit```

8. Test the connection with mysql commandline ```mysql -u root -p -h 127.0.0.1 -P 3307```</br>
  OR with mysql workbench (if you have it)</br>
  OR from any db browser

Disclaimer:
- Tested with mac m1
- This uses port 3307 on host to avoid any local installation of mysql
- 
