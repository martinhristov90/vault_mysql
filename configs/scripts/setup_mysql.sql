-- Original source https://github.com/berchev/update-e-mail-ruby/blob/master/scripts/setup_mysql.sql
-- Used just for testing
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'SET_YOUR_PASS';
GRANT GRANT OPTION ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- Create personal_info database
CREATE DATABASE test_db;

-- Slelect database personal_info for use
USE test_db;

-- Create table students
CREATE TABLE students (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL, 
    CONSTRAINT PK_students PRIMARY KEY (id)
);

-- Adding records into the table
INSERT INTO students 
    ( name, email)
VALUES 
    ('georgi', 'georgi@example.bg' ),
    ('martin', 'martin@example.bg' );
