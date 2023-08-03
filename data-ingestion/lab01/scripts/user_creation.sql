
-- Syntax for SQL Server and Azure SQL Database  
  
DROP USER  IF EXISTS midentityusp

CREATE USER midentityusp  FROM EXTERNAL PROVIDER;  


EXEC sys.sp_addrolemember   
    @rolename = N'db_datareader',  
    @membername = midentityusp  

EXEC sys.sp_addrolemember   
    @rolename = N'db_datawriter',  
    @membername = midentityusp 

EXEC sys.sp_addrolemember   
    @rolename = N'db_owner',  
    @membername = midentityusp  