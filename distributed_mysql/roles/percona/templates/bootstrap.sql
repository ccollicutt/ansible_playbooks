UPDATE mysql.user SET password=PASSWORD("{{ root_mysql_password }}") where user='root';
CREATE USER '{{ state_snapshot_transfer_user }}'@'localhost' IDENTIFIED BY '{{ state_snapshot_transfer_password }}';
GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{{ state_snapshot_transfer_user }}'@'%';
FLUSH PRIVILEGES;
