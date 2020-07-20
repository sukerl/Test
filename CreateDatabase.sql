CREATE DATABASE Test default character set utf8 default collate utf8_bin;
GRANT ALL PRIVILEGES ON Test.* TO 'Test_rwx'@'%' IDENTIFIED BY '1Test!';
GRANT SELECT, INSERT, UPDATE, DELETE ON  Test.* TO 'Test_rw'@'%' IDENTIFIED BY '1Test!';
GRANT SELECT ON Test.* TO 'Test_r'@'%' IDENTIFIED BY '1Test!';