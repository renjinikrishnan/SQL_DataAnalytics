-- Create the database
CREATE DATABASE IF NOT EXISTS practice_db;
USE practice_db;

-- Drop existing tables if any
DROP TABLE IF EXISTS OrderDetails, Orders, Products, Customers;

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50)
);

-- Insert Customers
INSERT INTO Customers (Name, Email, City, Country) VALUES
('John Doe', 'john@example.com', 'New York', 'USA'),
('Jane Smith', 'jane@example.com', 'London', 'UK'),
('Carlos Ruiz', 'carlos@example.com', 'Madrid', 'Spain'),
('Ananya Verma', 'ananya@example.com', 'Delhi', 'India'),
('Hiro Tanaka', 'hiro@example.com', 'Tokyo', 'Japan'),
('Laura Müller', 'laura@example.com', 'Berlin', 'Germany'),
('Mohamed Ali', 'mohamed@example.com', 'Cairo', 'Egypt'),
('Emma Watson', 'emma@example.com', 'Paris', 'France');

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Amount DECIMAL(10, 2),
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert Orders
INSERT INTO Orders (CustomerID, OrderDate, Amount, Status) VALUES
(1, '2023-05-10', 150.50, 'Completed'),
(2, '2023-06-11', 200.00, 'Pending'),
(3, '2023-06-15', 320.00, 'Shipped'),
(1, '2023-07-01', 450.75, 'Completed'),
(5, '2023-07-20', 600.00, 'Pending'),
(4, '2023-08-01', 175.00, 'Completed'),
(7, '2023-08-05', 120.00, 'Cancelled'),
(6, '2023-08-12', 780.00, 'Shipped');

-- Create Products table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2),
    Stock INT
);

-- Insert Products
INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Laptop', 'Electronics', 800.00, 10),
('Headphones', 'Electronics', 120.00, 50),
('Coffee Mug', 'Home', 15.50, 100),
('Notebook', 'Stationery', 5.25, 200),
('Smartphone', 'Electronics', 500.00, 20),
('Office Chair', 'Furniture', 150.00, 15),
('Desk Lamp', 'Home', 30.00, 60),
('Pen Set', 'Stationery', 10.00, 300);

-- Create OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 5),
(3, 4, 10),
(4, 1, 1),
(4, 3, 3),
(5, 5, 1),
(5, 2, 3),
(6, 7, 2),
(6, 8, 5),
(7, 2, 1),
(8, 1, 1),
(8, 5, 1),
(8, 6, 1);
