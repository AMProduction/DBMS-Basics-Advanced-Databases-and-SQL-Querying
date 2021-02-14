--Task 1
CREATE VIEW NumberCust AS
SELECT Sales.Customer.TerritoryID, COUNT (Sales.Customer.CustomerID) AS [CUSTOMERS COUNT] FROM Sales.Customer
GROUP BY Sales.Customer.TerritoryID

--Task 2.1
CREATE TABLE DeletedRowsServiceTable
(	DepartmentID smallint NOT NULL,
	Name nvarchar(50) NOT NULL,
	GroupName nvarchar(50) NOT NULL,
	ModifiedDate datetime NOT NULL,
);

CREATE TRIGGER trgDelete
ON HumanResources.Department
AFTER DELETE
AS
	BEGIN
		INSERT INTO DeletedRowsServiceTable
		SELECT * FROM deleted
	END
GO

--Task 2.2
CREATE TRIGGER trgUpdate
ON HumanResources.vEmployee
INSTEAD OF UPDATE
AS
	BEGIN
		PRINT 'The data cannot be updated at this view!'
		ROLLBACK TRANSACTION
	END
GO

--Task 3.1
CREATE PROCEDURE sp_ChangeCity
AS
SET NOCOUNT ON
UPDATE Person.Address
SET [City] = UPPER ([City])

--Task 3.2
CREATE PROCEDURE sp_GetLastName
@EmployeeID int
AS
SET NOCOUNT ON
SELECT [LastName] FROM Person.Person AS P
LEFT JOIN HumanResources.Employee AS E
ON P.BusinessEntityID = E.BusinessEntityID
WHERE E.BusinessEntityID = @EmployeeID

--Task 4
SELECT [OrganizationNode], [JobTitle], [MaritalStatus], [Gender] FROM [HumanResources].[Employee]
GROUP BY GROUPING SETS(
	([OrganizationNode]),
	([JobTitle], [MaritalStatus]),
	([JobTitle], [MaritalStatus], [Gender])
)

SELECT [OrganizationNode], [JobTitle], [MaritalStatus], [Gender] FROM [HumanResources].[Employee]
GROUP BY ROLLUP(
	([OrganizationNode]),
	([JobTitle], [MaritalStatus]),
	([JobTitle], [MaritalStatus], [Gender])
)

SELECT [OrganizationNode], [JobTitle], [MaritalStatus], [Gender] FROM [HumanResources].[Employee]
GROUP BY CUBE(
	([OrganizationNode]),
	([JobTitle], [MaritalStatus]),
	([JobTitle], [MaritalStatus], [Gender])
)

--Task 5
INSERT INTO dbo.XMLTableExample VALUES
('<bookstore_andriimalchyk>

  <book>
    <title>THE space odyssey</title>
    <author>A. Clarke</author>
    <year>1968</year>
    <price>100</price>
  </book>

  <book>
    <title>The witcher</title>
    <author>A.Sapkowskiy</author>
    <year>2005</year>
    <price>200</price>
  </book>

</bookstore_andriimalchyk>'
)

SELECT * FROM dbo.XMLTableExample

DECLARE @xmlhandle INT
DECLARE @xmlinput XML
SET @xmlinput = (SELECT [XMLdata] FROM [dbo].[XMLTableExample])

EXEC sp_xml_preparedocument @xmlhandle OUTPUT, @xmlinput

SELECT * FROM sys.dm_exec_xml_handles (0)

SELECT * INTO XMLConverted FROM OPENXML(@xmlhandle, '/bookstore_andriimalchyk/book', 2)
WITH (title VARCHAR(40), author VARCHAR(40), [year] smallint, price Money)			
EXEC sp_xml_removedocument @xmlhandle
SELECT * FROM XMLConverted

--Task 6
CREATE PARTITION FUNCTION PartitionFunction1 (int)  
    AS RANGE RIGHT FOR VALUES (50) ;  
GO 

CREATE PARTITION SCHEME PartitionScheme1 
    AS PARTITION PartitionFunction1  
    TO (FG1, FG2) ;  
GO 

CREATE TABLE PartitionTable1 (ID int PRIMARY KEY, FirstName varchar(40))  
    ON PartitionScheme1(ID) ;  
GO  

SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.partition_id, i.data_space_id, f.function_id, 
f.type_desc, r.boundary_id, r.value AS BoundaryValue   
FROM sys.tables AS t  
JOIN sys.indexes AS i  
    ON t.object_id = i.object_id  
JOIN sys.partitions AS p  
    ON i.object_id = p.object_id AND i.index_id = p.index_id   
JOIN  sys.partition_schemes AS s   
    ON i.data_space_id = s.data_space_id  
JOIN sys.partition_functions AS f   
    ON s.function_id = f.function_id  
LEFT JOIN sys.partition_range_values AS r   
    ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
WHERE t.name = 'PartitionTable1' AND i.type <= 1  
ORDER BY p.partition_number; 

--Task 7
INSERT INTO GeometryTasks (GeometryData)
VALUES 
	('Point(1 1)')
	,('Point(-1 1)')
	,('Polygon((0 0.5, -0.2 0, 0 -0.2, 0.2 0, 0 0.5))')
	,('CURVEPOLYGON(Circularstring(1 1.5, 1.5 1, 1 0.5, 0.5 1, 1 1.5))')
	,('CURVEPOLYGON(Circularstring(-1 1.5, -0.5 1, -1 0.5, -1.5 1, -1 1.5))')
	,('CURVEPOLYGON(Circularstring(-1.5 -0.5, 0.8 -1.5, 1.5 -0.2, 0 -1, -1.5 -0.5))')
	,('CURVEPOLYGON(Circularstring(3 0, 0 -3, -3 0, 0 3, 3 0))')