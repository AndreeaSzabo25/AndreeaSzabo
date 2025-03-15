CREATE DATABASE Project

CREATE TYPE OrderNumber
FROM VARCHAR(255)
CREATE TYPE AccountNumber
FROM VARCHAR(255)
CREATE TYPE Flag
FROM bit
CREATE TYPE Name
FROM VARCHAR(255)

CREATE TABLE SalesTerritory(TerritoryID INT,
Name name NOT NULL,
CountryRegionCode VARCHAR(255) NOT NULL,
[Group] VARCHAR(255) NOT NULL,
SalesYTD money NOT NULL,
SalesLastYear money NOT NULL,
CostYTD money NOT NULL,
CostLastYear money NOT NULL,
rowguid uniqueidentifier NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT TerritoryID_PK PRIMARY KEY(TerritoryID))

CREATE TABLE CreditCard(CreditCardID INT,
CardType VARCHAR(255) NOT NULL,
CardNumber VARCHAR(255) NOT NULL,
ExpMonth SMALLINT NOT NULL,
ExpYear SMALLINT NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT CreditCardID_PK PRIMARY KEY(CreditCardID))

CREATE TABLE Address( AdressID int,
AddressLine1 varchar(255) NOT NULL,
AddressLine2 varchar(255),
City varchar(255) NOT NULL,
StateProvinceID int NOT NULL,
PostalCode varchar(255) NOT NULL,
rowguid uniqueidentifier NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT AddressID_PK PRIMARY KEY(AdressID))

CREATE TABLE ShipMethod (ShipMethodID int,
Name name NOT NULL,
ShipBase money NOT NULL,
ShipRate money NOT NULL,
rowguid uniqueidentifier NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT ShipMethodID_PK PRIMARY KEY(ShipMethodID))

CREATE TABLE CurrencyRate (CurrencyRateID int,
CurrencyRateDate datetime not null,
FromCurrencyCode varchar(255) not null,
ToCurrencyCode varchar(255) not null,
AverageRate money not null,
EndOfDayRate money not null,
ModifiedDate datetime NOT NULL,
CONSTRAINT CurrencyRateID_PK PRIMARY KEY(CurrencyRateID))

CREATE TABLE SpecialOfferProduct (SpecialOfferID int,
ProductID int,
rowguid uniqueidentifier NOT NULL,
ModifiedDate datetime NOT NULL,
CONSTRAINT SpOf_Pr_PK PRIMARY KEY (SpecialOfferID,ProductID))

 CREATE TABLE Customer(CustomerID INT, 
   PersonID INT, 
   StoreID INT,
   TerritoryID INT,
   AccountNumber AccountNumber not null, 
   rowguid uniqueidentifier not null,
   ModifiedDate datetime not null,
   CONSTRAINT CustomerID_PK PRIMARY KEY (CustomerID),
    CONSTRAINT Customer_FK_SalesTer FOREIGN KEY (TerritoryID) REFERENCES SalesTerritory(TerritoryID))

CREATE TABLE SalesPerson (BusinessEntityID INT, 
    TerritoryID INT,
   SalesQuota money,
   Bonus money not null,
   CommissionPct money not null,
   SalesYTD money not null,
   SalesLastYear money not null,
   rowguid uniqueidentifier not null,
   ModifiedDate datetime not null,
   CONSTRAINT BusinessEntityID_PK PRIMARY KEY (BusinessEntityID),
    CONSTRAINT SalesPerson_FK_SalesTer FOREIGN KEY (TerritoryID) REFERENCES SalesTerritory(TerritoryID))

CREATE TABLE SalesOrderHeader (SalesOrderID INT, 
   RevisionNumber INT not null,
   OrderDate datetime not null,
   DueDate datetime not null,
   ShipDate datetime ,
   Status INT not null,
   OnlineOrderFlag Flag,
   SalesOrderNumber varchar(255)not null, 
   PurchaseOrderNumber OrderNumber,
   AccountNumber Accountnumber,
   CustomerID int not null,
   SalesPersonID int,
   TerritoryID int,
   BillToAdressID int not null,
   ShipToAdressID int not null,
   ShipMethodID int not null,
   CreditCardID int,
   CreditCardApprovalCode varchar(255),
   CurrencyRateID int,
   SubTotal money not null,
   TaxAmt money not null,
   Freight money not null
   CONSTRAINT SalesOrder_PK PRIMARY KEY (SalesOrderID),
    CONSTRAINT Customer_FK_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT SalesPerson_FK_SalesPerson FOREIGN KEY (SalesPersonID) REFERENCES SalesPerson(BusinessEntityID ),
CONSTRAINT Territory_FK_SalesTer FOREIGN KEY (TerritoryID) REFERENCES SalesTerritory(TerritoryID), 
CONSTRAINT BillToAdress_FK_Address FOREIGN KEY (BillToAdressID) REFERENCES Address(AdressID),
CONSTRAINT ShipMethod_FK_ShipMethod FOREIGN KEY (ShipMethodID) REFERENCES ShipMethod(ShipMethodID),
CONSTRAINT CreditCard_FK_CreditCard FOREIGN KEY (CreditCardID) REFERENCES CreditCard(CreditCardID),
CONSTRAINT CurrencyRate_FK_CurrencyRate FOREIGN KEY (CurrencyRateID) REFERENCES CurrencyRate(CurrencyRateID))

CREATE TABLE SalesOrderDetail (SalesOrderID INT, 
   SalesOrderDetailID INT,
   CarrierTrackingNumber varchar(255),
   OrderQty int not null,
   ProductID int not null,
   SpecialOfferID int not null,
   UnitPrice money not null,
   UnitPriceDiscount money not null,
   Linetotal int,
   rowguid uniqueidentifier not null,
   ModifiedDate datetime not null,
   CONSTRAINT SalesOrder_SalesOrderDetail_PK PRIMARY KEY (SalesOrderID,SalesOrderDetailID),
    CONSTRAINT SpecialOffer_Product_FK_SpecialOfferProduct FOREIGN KEY ( SpecialOfferID , ProductID) REFERENCES SpecialOfferProduct( SpecialOfferID , ProductID))
 
ALTER TABLE SalesOrderDetail
ADD CONSTRAINT SalesOrder_FK_SalesOrderHeader FOREIGN KEY ( SalesOrderID) REFERENCES SalesOrderHeader ( SalesOrderID)

INSERT INTO  SalesTerritory VALUES 
(1,'North','US', 'NY', 250 , 200, 150, 120,NEWID(),'2024/01/20'),
 (2,'South','UK', 'BY', 350 , 225, 170, 180,NEWID(),'2024/03/15'),
 (3,'East','RO', 'BUC', 315 , 195, 200, 135 ,NEWID(),'2024/05/19')

 INSERT INTO  CreditCard VALUES 
 (156,'Visa', 45801234, 02, 2026,'2024/06/30'),
 (234,'Diners', 57713251, 05,2025,'2024/08/16'),
 (325, 'MasterCard', 52213661,03,2028, '2024/07/26')

  INSERT INTO  Address VALUES 
  (789,'Maabarot','Keller' ,'Haifa',04, 'Hai04',NEWID(), '2024/03/25'),
  ( 456,'Vradim','Ilanot','Tel Aviv',03, 'Tlv03',NEWID(), '2024/08/02'),
  ( 123,'Shoshana','Yam','Rehovot',05, 'Rhv05',NEWID(), '2024/09/05')

  INSERT INTO  ShipMethod VALUES 
  (777,'By sea', 753, 357, NEWID(), '2024/03/26'),
  ( 444,'Byland', 951,159 ,NEWID(), '2024/08/03'),
  ( 111,'By air',654 ,564 ,NEWID(), '2024/09/08')

  INSERT INTO  CurrencyRate VALUES 
  (78, '2024/01/02', '45z','12x', 4.5, 5.1,'2024/01/02'),
  (89, '2024/01/03', '45z','12x', 4.3, 4.9,'2024/01/03'),
  (63, '2024/01/04', '45z','12x', 4.8, 5.5,'2024/01/04')

  INSERT INTO  SpecialOfferProduct VALUES
  (10, 888, NEWID(), '2024/03/26'),
  (20, 777, NEWID(), '2024/01/05'),
  (30, 555, NEWID(), '2024/09/12')

   INSERT INTO  Customer VALUES
   (22, 221, 661, 1, '124578', NEWID(),'2024/04/26'),
   (33, 223, 655, 2,'256369', NEWID(),'2024/10/28'),
   (44, 226, 688, 3, '741852', NEWID(), '2024/11/07')

   INSERT INTO  SalesPerson VALUES
   ( 1234, 1,8585.1, 156.5, 20, 250 , 200, NEWID(),'2024/01/20'), 
   (5678, 2, 2564.6, 250.2, 35, 350 , 225, NEWID(),'2024/03/15'),
   (9012, 3, 2115, 180.5, 28, 315 , 195,NEWID(),'2024/05/19')

   INSERT INTO SalesOrderHeader VALUES
   (550, 91,'2024/01/11','2024/01/13','2024/01/15',15, 0,'AAS','b123n','kek123', 22, 1234, 1, 789, 789, 777, 156, '0AS01', 78,2251, 256,51),
   (560, 92, '2024/02/15','2024/02/18','2024/02/21',16, 1,'AAV','b223b','dee564', 33, 5678, 2, 456, 456, 444, 234, '0SD05', 89,2561,365,58),
   (570, 93,'2024/05/18', '2024/05/20','2024/03/25',15, 1,'AVA','b125a','fre587', 44, 9012, 3, 123, 123, 111, 325, '0FRD09', 63,3561,421,56)

    INSERT INTO SalesOrderDetail VALUES
   (550, 11, 'vb1', 39, 888, 10, 23.5, 5.2, 80, NEWID(), '2024/01/20'),
   (560, 12, 'cb2', 96, 777, 20, 20.2, 3.5, 110, NEWID(), '2024/03/15'),
   (570, 13,'sd5', 69, 555, 30, 11.9, 2.6, 100, NEWID(),'2024/05/19' )
