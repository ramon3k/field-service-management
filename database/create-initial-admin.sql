-- Create Initial System Admin User
-- This script creates the first admin user for a new installation
-- 
-- IMPORTANT: Change the password immediately after first login!
--
-- Default credentials:
--   Username: admin_001
--   Password: Admin123!
--
-- You can customize the values below before running this script

DECLARE @CompanyCode NVARCHAR(10) = 'CHANGEME'  -- *** CHANGE THIS to your company code ***
DECLARE @Username NVARCHAR(50) = 'admin_001'
DECLARE @Password NVARCHAR(255) = 'Admin123!'    -- *** CHANGE THIS for security ***
DECLARE @FullName NVARCHAR(100) = 'System Administrator'
DECLARE @Email NVARCHAR(100) = 'admin@yourcompany.com'  -- *** CHANGE THIS ***

-- Check if user already exists
IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username AND CompanyCode = @CompanyCode)
BEGIN
    PRINT 'User already exists. Skipping creation.'
    PRINT 'If you need to reset the password, run the reset-admin-password.sql script instead.'
END
ELSE
BEGIN
    -- Create the admin user
    INSERT INTO Users (
        Username,
        PasswordHash,
        FullName,
        Email,
        Role,
        CompanyCode,
        IsActive,
        CreatedAt
    )
    VALUES (
        @Username,
        @Password,  -- In production, this should be hashed. The app will handle password hashing on first login.
        @FullName,
        @Email,
        'SystemAdmin',
        @CompanyCode,
        1,
        GETUTCDATE()
    )

    PRINT '✓ System Admin user created successfully!'
    PRINT ''
    PRINT '========================================='
    PRINT 'IMPORTANT: Save these credentials!'
    PRINT '========================================='
    PRINT 'Username: ' + @Username
    PRINT 'Password: ' + @Password
    PRINT 'Company Code: ' + @CompanyCode
    PRINT ''
    PRINT '*** CHANGE THE PASSWORD IMMEDIATELY AFTER FIRST LOGIN ***'
    PRINT ''
    PRINT 'Login URL: [Your application URL will be shown after deployment]'
END
GO
