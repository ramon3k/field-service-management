-- Reset System Admin Password
-- Use this script if you've forgotten the admin password or need to reset it
--
-- IMPORTANT: Run this with caution and change the password immediately after logging in!

DECLARE @CompanyCode NVARCHAR(10) = 'CHANGEME'  -- *** CHANGE THIS to your company code ***
DECLARE @Username NVARCHAR(50) = 'admin_001'
DECLARE @NewPassword NVARCHAR(255) = 'NewAdmin123!'  -- *** CHANGE THIS ***

-- Check if user exists
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = @Username AND CompanyCode = @CompanyCode)
BEGIN
    PRINT 'ERROR: User not found!'
    PRINT 'Username: ' + @Username
    PRINT 'Company Code: ' + @CompanyCode
    PRINT ''
    PRINT 'Please check the username and company code and try again.'
END
ELSE
BEGIN
    -- Reset the password
    UPDATE Users
    SET PasswordHash = @NewPassword,
        IsActive = 1  -- Ensure account is active
    WHERE Username = @Username
      AND CompanyCode = @CompanyCode

    PRINT '✓ Password reset successfully!'
    PRINT ''
    PRINT '========================================='
    PRINT 'New Credentials:'
    PRINT '========================================='
    PRINT 'Username: ' + @Username
    PRINT 'Password: ' + @NewPassword
    PRINT 'Company Code: ' + @CompanyCode
    PRINT ''
    PRINT '*** CHANGE THE PASSWORD IMMEDIATELY AFTER LOGIN ***'
END
GO
