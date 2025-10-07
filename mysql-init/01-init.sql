-- Create databases only if they don't exist (preserve existing data)
CREATE DATABASE IF NOT EXISTS traccar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS traccar_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create users only if they don't exist (preserve existing users and their data)
CREATE USER IF NOT EXISTS 'traccar'@'%' IDENTIFIED WITH mysql_native_password BY 'traccar_password';
CREATE USER IF NOT EXISTS 'traccar'@'localhost' IDENTIFIED WITH mysql_native_password BY 'traccar_password';

-- Ensure the user has the correct authentication method (in case of container recreation)
ALTER USER 'traccar'@'%' IDENTIFIED WITH mysql_native_password BY 'traccar_password';
ALTER USER 'traccar'@'localhost' IDENTIFIED WITH mysql_native_password BY 'traccar_password';

-- Grant all privileges on both databases for both users
GRANT ALL PRIVILEGES ON traccar.* TO 'traccar'@'%';
GRANT ALL PRIVILEGES ON traccar.* TO 'traccar'@'localhost';
GRANT ALL PRIVILEGES ON traccar_test.* TO 'traccar'@'%';
GRANT ALL PRIVILEGES ON traccar_test.* TO 'traccar'@'localhost';

-- Create DBeaver user for external database tools
CREATE USER IF NOT EXISTS 'dbeaver'@'%' IDENTIFIED WITH mysql_native_password BY 'dbeaver123';
CREATE USER IF NOT EXISTS 'dbeaver'@'localhost' IDENTIFIED WITH mysql_native_password BY 'dbeaver123';
GRANT ALL PRIVILEGES ON traccar.* TO 'dbeaver'@'%';
GRANT ALL PRIVILEGES ON traccar.* TO 'dbeaver'@'localhost';
GRANT ALL PRIVILEGES ON traccar_test.* TO 'dbeaver'@'%';
GRANT ALL PRIVILEGES ON traccar_test.* TO 'dbeaver'@'localhost';

-- Create root user for external connections (for troubleshooting)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'traccar_password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Flush privileges
FLUSH PRIVILEGES;

-- Show created users
SELECT User, Host, plugin FROM mysql.user WHERE User IN ('traccar', 'dbeaver', 'root');