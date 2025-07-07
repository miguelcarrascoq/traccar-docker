# Traccar Docker Troubleshooting Guide

This guide addresses common issues with the Traccar Docker setup, especially related to Docker credentials and GitHub authentication.

## 1. Docker Credential Helper Issue

If you're seeing errors like:
```
error getting credentials - err: exec: "docker-credential-desktop": executable file not found in $PATH
```

This means Docker can't find the credential helper it needs. Use our `fix-docker-build.sh` script:

```bash
./fix-docker-build.sh
```

This script:
- Adds Docker's bin directory to PATH
- Creates a symlink to the credential helper

## 2. Database Migration Issues

If you see errors like this in the traccar-backend logs:
```
ERROR: ChangeSet changelog-6.7::changelog-6.7::author encountered an exception.
ERROR: Main method error - Table 'tc_actions' already exists - SQLSyntaxErrorException
```

This is likely due to a mismatch between the database schema and the migration scripts. To fix this:

### Option 1: Use the --reset-db flag (Recommended)

We've added a convenient flag to automatically reset the database:

```bash
./fix-docker-build.sh --reset-db
```

This will:
- Stop all running containers
- Remove the MySQL data volume
- Rebuild and restart all containers with a fresh database

### Option 2: Manual steps

If you prefer to do it manually:

1. Stop all containers:
   ```bash
   docker compose down
   ```

2. Remove the MySQL volume:
   ```bash
   docker volume rm traccar-docker_mysql_data
   ```

3. Start containers again:
   ```bash
   docker compose up -d
   ```

This will create a fresh database and allow the migrations to run correctly.

## 3. GitHub Authentication Issues

If you're seeing authentication errors when pulling from private GitHub repositories:

### Using Personal Access Tokens (Recommended)

1. Create a Personal Access Token in GitHub:
   - Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Generate new token
   - Select at least the `repo` scope
   - Copy the generated token

2. Update your `.env` file:
   - Use your GitHub username for `GIT_USERNAME`
   - Use your Personal Access Token for `GIT_PASSWORD` (not your password)
   
   Example:
   ```
   GIT_USERNAME=yourusername
   GIT_PASSWORD=ghp_123456789abcdefghijklmnopqrstuvwxyz
   ```

3. We've provided a template file at `.env.example`. Edit it with your token:
   ```bash
   cp .env.example .env
   # Then edit .env with your token
   nano .env
   ```

## 4. Platform Architecture Issues

If you see platform mismatch warnings (particularly on M1/M2 Macs):

These warnings are informational and shouldn't prevent operation. We've updated the docker-compose.yml file to specify platform compatibility.

## 5. Building and Running

After addressing the above issues, run:

```bash
docker compose down    # Stop existing containers if any
docker compose build   # Rebuild with new configurations
docker compose up -d   # Start containers in the background
```

Or use our helper script:

```bash
./fix-docker-build.sh
```

## 6. Manual Docker Compose Commands

If you need to run Docker Compose with specific settings:

```bash
# Specify credential helper location
PATH=$HOME/.docker/bin:$HOME/bin:$PATH docker compose build

# Force arm64 platform (for M1/M2 Macs)
docker compose build --build-arg BUILDKIT_PLATFORM=linux/arm64
```

## 7. Viewing Logs

To see container logs:

```bash
docker compose logs -f
# Or for a specific container
docker compose logs -f traccar-backend
```

## Access URLs

- Frontend: http://localhost:3000
- Backend: http://localhost:8082
- Database: http://localhost:8080 (phpMyAdmin)

Default login: admin / admin
