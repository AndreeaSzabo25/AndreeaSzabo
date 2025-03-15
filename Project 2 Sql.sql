/* שאלה מס 1 */

SELECT ProductID, Name,Color,ListPrice, Size
FROM Production.Product 
EXCEPT
SELECT PP.ProductID, PP.Name, PP.Color,PP.ListPrice, PP.Size
FROM Production.Product PP JOIN Sales.SalesOrderDetail SSOD
ON  PP.ProductID= SSOD.ProductID

/* שאלה מס 2 */

UPDATE sales.customer SET personid=customerid
 WHERE customerid <=290
UPDATE sales.customer  SET personid=customerid+1700
 WHERE customerid >= 300 and customerid<=350
UPDATE sales.customer SET personid=customerid+1700
  WHERE customerid >= 352 and customerid<=701



SELECT SC.CustomerID ,ISNULL(PER.FirstName,'Unknown') AS First_Name,ISNULL(PER.LastName ,'Unknown') AS Last_Name 
FROM  Sales.Customer SC LEFT JOIN Person.Person PER
ON SC.PersonID=PER.BusinessEntityID 
WHERE SC.CustomerID  IN (SELECT CustomerID      
FROM  Sales.Customer
EXCEPT 
SELECT CustomerID 
FROM Sales.SalesOrderHeader )
ORDER BY SC.CustomerID

/* שאלה מס 3 */

SELECT SC.CustomerID ,PER.FirstName,PER.LastName , CNT.CountOfOrders 
FROM  Sales.Customer SC  JOIN Person.Person PER
ON SC.PersonID=PER.BusinessEntityID 
JOIN (SELECT TOP 10 CustomerID, COUNT(*) AS CountOfOrders  
FROM  Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CountOfOrders DESC) CNT
ON SC.CustomerID =CNT.CustomerID 

/* שאלה מס 4 */

SELECT PER.FirstName, PER.LastName, HRE.JobTitle, HRE.HireDate,
COUNT(*) OVER (PARTITION BY HRE.JobTitle) AS CountOfTitle
FROM HumanResources.Employee HRE JOIN Person.Person PER
ON HRE.BusinessEntityID=PER.BusinessEntityID


/* שאלה מס 5  */

SELECT LAST_O.SalesOrderID ,LAST_O.CustomerID, PER.FirstName, PER.LastName, LAST_O.OrderDate,PREVIOUS_O. OrderDate
FROM
(SELECT SalesOrderID,CustomerID, OrderDate 
FROM
(SELECT SalesOrderID, CustomerID, OrderDate,
ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC) AS RN1
FROM Sales.SalesOrderHeader)AS L
WHERE L.RN1=1)AS LAST_O
LEFT JOIN
(SELECT SalesOrderID,CustomerID, OrderDate 
FROM(SELECT SalesOrderID, CustomerID, OrderDate,
ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate DESC) AS RN2
FROM Sales.SalesOrderHeader)AS P
WHERE RN2=2 )AS PREVIOUS_O
ON LAST_O.CustomerID=PREVIOUS_O.CustomerID
JOIN Sales.Customer SC 
ON LAST_O.CustomerID=SC.CustomerID
JOIN Person.Person PER
ON SC.PersonID = PER.BusinessEntityID


/* שאלה מס 6 */


SELECT X.YEAR ,X.SalesID, X.L_Name, X.F_Name, ROUND(X.Total,1) AS TOTAL
FROM 
(SELECT YEAR(SOH.OrderDate) AS 'YEAR', SOH.SalesOrderID AS SalesID , PER.LastName AS L_Name, PER.FirstName AS F_Name, 
SUM(SOD.UnitPrice*(1- SOD.UnitPriceDiscount )* SOD.OrderQty)AS Total,
RANK()OVER (PARTITION BY YEAR(SOH.OrderDate) ORDER BY SUM(SOD.UnitPrice*(1- SOD.UnitPriceDiscount )* SOD.OrderQty) DESC) AS RNK
FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
JOIN Sales.Customer SC
ON SOH.CustomerID=SC.CustomerID
JOIN  Person.Person PER
ON SC.PersonID= PER.BusinessEntityID
GROUP BY YEAR(SOH.OrderDate), SOH.SalesOrderID , PER.LastName , PER.FirstName) AS X
WHERE X.RNK=1


/* שאלה מס 7 */

SELECT Month , [2011], [2012], [2013], [2014]
FROM
(SELECT SalesOrderID, YEAR(OrderDate) AS Year , MONTH(OrderDate) AS Month
FROM Sales.SalesOrderHeader) AS SOURCE
PIVOT (COUNT(SalesOrderID) FOR Year IN ([2011],[2012],[2013], [2014])) NEW
ORDER BY Month

/* שאלה מס 8 */

SELECT OBM.Year,
ISNULL(CAST(OBM.Month AS VARCHAR) ,'Grand Total')AS Month_No, 
OBM.Sum_Price ,
ISNULL(OBM.Cum_Sum, LAG(OBM.Cum_Sum,1) OVER (PARTITION BY OBM.Year ORDER BY  OBM.Year )) AS Cum_Sum
FROM
(SELECT YEAR(SOH.OrderDate) AS Year,
MONTH(SOH.OrderDate) AS Month,
SUM(SOD.UnitPrice ) AS Sum_Price,
SUM( SUM(SOD.UnitPrice)) OVER (PARTITION BY YEAR(SOH.OrderDate) ORDER BY MONTH(SOH.OrderDate)ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cum_Sum
FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(SOH.OrderDate),MONTH(SOH.OrderDate)) AS OBM
GROUP BY GROUPING SETS ((OBM.Year , OBM.Month , OBM.Sum_Price, OBM.Cum_Sum), OBM.Year)


/* שאלה מס 9 */

SELECT X.DepartmentName,
X.EmployeeID,
X.EmployesFullName,
X.HireDate, 
X.Seniority,
LEAD(X.EmployesFullName , 1) OVER (PARTITION BY X.DepartmentID ORDER BY X.HireDate DESC) AS PreviousEmpName,
LEAD(X.HireDate , 1) OVER (PARTITION BY X.DepartmentID ORDER BY X.HireDate DESC) AS PreviousEmpDate,
DATEDIFF (DD,LEAD(X.HireDate , 1) OVER (PARTITION BY X.DepartmentID ORDER BY X.HireDate DESC) ,X.HireDate) AS DiffDays
FROM
(SELECT HRD.DepartmentID  AS DepartmentID,
HRD.Name AS DepartmentName,
HRE.BusinessEntityID AS EmployeeID ,
(PER.FirstName+' '+ PER.LastName) AS EmployesFullName ,
HRE.HireDate AS HireDate , 
DATEDIFF (MM, HRE.HireDate, GETDATE()) AS Seniority
FROM HumanResources.Employee HRE JOIN Person.Person PER
ON HRE.BusinessEntityID=PER.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory HEDH
ON HRE.BusinessEntityID=HEDH.BusinessEntityID
JOIN HumanResources.Department HRD
ON HRD.DepartmentID=HEDH.DepartmentID )AS X
ORDER BY X.DepartmentName,X.HireDate DESC