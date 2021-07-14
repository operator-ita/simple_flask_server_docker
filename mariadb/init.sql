CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;

CREATE TABLE IF NOT EXISTS Persons (
    PersonID INT NOT NULL,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

IF NOT EXISTS ( SELECT 1 FROM Persons WHERE FirstName = 'John' AND LastName = 'Doe' )
BEGIN
    INSERT INTO Persons (PersonID , LastName, FirstName, Address, City)
    VALUES (1, 'Doe', 'John', '1178 Confederate Drive','NY')
END

