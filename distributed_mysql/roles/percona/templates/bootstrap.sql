UPDATE mysql.user SET password=PASSWORD("Passw0rd") where user='root';
CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 's3cret';
GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'%';
FLUSH PRIVILEGES;
