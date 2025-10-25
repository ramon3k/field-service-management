-- Update DCPSP admin user to SystemAdmin role
USE FieldServiceDB;
GO

-- Update the admin user role
UPDATE Users 
SET Role = 'SystemAdmin'
WHERE Username = 'admin' 
  AND CompanyCode = 'EXAMPLE';

-- Verify the update
SELECT 
    ID,
    Username,
    FullName,
    Role,
    CompanyCode,
    IsActive
FROM Users
WHERE Username = 'admin' 
  AND CompanyCode = 'EXAMPLE';

PRINT '✅ Admin user updated to SystemAdmin role';
