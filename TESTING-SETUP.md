# Testing Environment Setup

This document explains how to use the separate testing environment to prevent test data from contaminating your production database.

## Problem Solved

Previously, when you restarted the development environment with `./start-dev.sh`, the database would be reset and you'd lose all your Traccar users and Laravel users. Additionally, any test data created during development would mix with your production data.

## Solution

We now have **two separate environments**:

1. **Development Environment** (`./start-dev.sh`) - For your production data
2. **Testing Environment** (`./start-test.sh`) - For testing and experimentation

## Quick Start

### Development Environment (Production Data)
```bash
# Start development environment
./start-dev.sh

# Stop development environment
./stop-dev.sh
```

### Testing Environment (Test Data)
```bash
# Start testing environment
./start-test.sh

# Stop testing environment
./stop-test.sh
```

## Environment Details

### Development Environment
- **Backend API**: http://localhost:8082
- **MySQL**: localhost:3306
- **phpMyAdmin**: http://localhost:8080
- **Database**: `traccar` (production data)
- **Data Persistence**: ✅ Your users and data persist across restarts

### Testing Environment
- **Backend API**: http://localhost:8084
- **MySQL**: localhost:3307
- **phpMyAdmin**: http://localhost:8081
- **Database**: `traccar_test` (test data only)
- **Data Isolation**: ✅ Completely separate from production data

## Key Features

### 1. Data Persistence
- **Development database**: Your Traccar users and Laravel users are preserved across restarts
- **No more data loss**: The MySQL init script now uses `CREATE DATABASE IF NOT EXISTS` instead of dropping databases

### 2. Data Isolation
- **Separate databases**: Production data (`traccar`) and test data (`traccar_test`) are completely isolated
- **Different ports**: Each environment uses different ports to avoid conflicts
- **Independent volumes**: Each environment has its own MySQL data volume

### 3. Easy Management
- **Simple scripts**: Just run `./start-dev.sh` or `./start-test.sh`
- **Clear separation**: No confusion about which environment you're working with

## Database Configuration

### Development Database
- **Name**: `traccar`
- **User**: `traccar`
- **Password**: `traccar_password`
- **Port**: 3306

### Testing Database
- **Name**: `traccar_test`
- **User**: `traccar_test`
- **Password**: `traccar_test_password`
- **Port**: 3307

## Usage Recommendations

### For Development Work
1. Use `./start-dev.sh` for your main development work
2. Create your Traccar users and Laravel users in this environment
3. Your data will persist across restarts

### For Testing
1. Use `./start-test.sh` when you need to test new features
2. Create test users and test data in this environment
3. Feel free to reset this environment without affecting your production data

### For Clean Testing
If you want to start fresh with the testing environment:
```bash
# Stop testing environment
./stop-test.sh

# Remove test database volume (this will delete all test data)
docker volume rm traccar-docker_mysql_test_data

# Start fresh testing environment
./start-test.sh
```

## Troubleshooting

### If you see "test" users in your development database
This is normal behavior when Traccar starts with an empty database. The first user to register becomes an administrator. To avoid this:
1. Always create your users through the web interface
2. Use the testing environment for experimentation

### If you need to reset the development database
```bash
# Stop development environment
./stop-dev.sh

# Remove development database volume (WARNING: This deletes all data!)
docker volume rm traccar-docker_mysql_data

# Start fresh development environment
./start-dev.sh
```

## File Structure

```
traccar-docker/
├── docker-compose.yml          # Production environment
├── docker-compose.dev.yml      # Development environment
├── docker-compose.test.yml     # Testing environment
├── mysql-init/
│   └── 01-init.sql            # Development database init
├── mysql-init-test/
│   └── 01-init-test.sql       # Testing database init
├── traccar/
│   ├── traccar.xml            # Development config
│   └── traccar-test.xml       # Testing config
├── start-dev.sh               # Start development
├── stop-dev.sh                # Stop development
├── start-test.sh              # Start testing
├── stop-test.sh               # Stop testing
├── run-laravel-tests.sh       # Run Laravel tests safely
└── test-setup.sh              # Verify configuration

interno-laravel/
├── .env.testing               # Testing environment config
├── phpunit.xml                # Updated for testing database
├── tests/
│   ├── Pest.php              # Updated with RefreshDatabase
│   └── TestCase.php          # Updated with RefreshDatabase
└── run-tests-safe.sh          # Safe test execution script
```

## Laravel Testing Integration

### Problem Solved
Previously, when running Laravel tests with Pest, they were using the same database as your development environment, causing data contamination.

### Solution
Laravel tests now use a completely separate testing database:

- **Development Database**: `traccar` (port 3306) - Your production data
- **Testing Database**: `traccar_test` (port 3307) - Test data only

### Running Laravel Tests Safely

#### Option 1: Using the integrated script (Recommended)
```bash
# From traccar-docker directory
./run-laravel-tests.sh
```

This script will:
1. Start the testing environment
2. Run Laravel tests using the separate testing database
3. Ensure no data contamination

#### Option 2: Manual execution
```bash
# Start testing environment first
./start-test.sh

# Then run Laravel tests from the Laravel project
cd ../interno-laravel
./run-tests-safe.sh
```

### Laravel Test Configuration

The Laravel project has been configured with:

1. **`.env.testing`** - Separate environment file for testing
2. **`phpunit.xml`** - Updated to use the testing database
3. **`RefreshDatabase`** - Enabled to ensure clean test runs
4. **Safe test script** - `run-tests-safe.sh` for secure test execution

### Key Features

- **Complete isolation**: Laravel tests use `traccar_test` database
- **No data loss**: Your development data remains untouched
- **Automatic cleanup**: Tests run in transactions and are rolled back
- **Easy execution**: Simple commands to run tests safely

## Verification and Testing

### Verify Your Setup
To ensure everything is configured correctly, run the verification script:

```bash
./test-setup.sh
```

This script will:
1. ✅ Start both development and testing environments
2. ✅ Verify database connections
3. ✅ Confirm complete isolation between environments
4. ✅ Check Laravel test configuration
5. ✅ Provide usage instructions

### What the Verification Checks

- **Database Isolation**: Confirms `traccar` (port 3306) and `traccar_test` (port 3307) are separate
- **Connection Health**: Verifies both databases are accessible
- **Laravel Integration**: Checks if Laravel test scripts are properly configured
- **Environment Separation**: Ensures no cross-contamination between environments

## Benefits

1. **No more data loss**: Your development data persists across restarts
2. **Clean testing**: Test data doesn't contaminate production data
3. **Easy switching**: Simple commands to switch between environments
4. **Isolated databases**: Complete separation of concerns
5. **Flexible workflow**: Use the right environment for the right task
6. **Laravel integration**: Safe testing for both Traccar and Laravel projects

## Quick Reference

### Essential Commands

| Command | Purpose | Environment |
|---------|---------|-------------|
| `./start-dev.sh` | Start development environment | Development (port 3306) |
| `./stop-dev.sh` | Stop development environment | Development |
| `./start-test.sh` | Start testing environment | Testing (port 3307) |
| `./stop-test.sh` | Stop testing environment | Testing |
| `./run-laravel-tests.sh` | Run Laravel tests safely | Testing |
| `./test-setup.sh` | Verify configuration | Both |

### Database Access

| Environment | Database | Port | User | Password |
|-------------|----------|------|------|----------|
| Development | `traccar` | 3306 | `traccar` | `traccar_password` |
| Testing | `traccar_test` | 3307 | `traccar_test` | `traccar_test_password` |

### Web Interfaces

| Service | Development | Testing |
|---------|-------------|---------|
| Backend API | http://localhost:8082 | http://localhost:8084 |
| phpMyAdmin | http://localhost:8080 | http://localhost:8081 |
| MySQL | localhost:3306 | localhost:3307 |

### Laravel Commands

```bash
# From traccar-docker directory
./run-laravel-tests.sh

# From interno-laravel directory
./run-tests-safe.sh
```
