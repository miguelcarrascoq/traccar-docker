# Private Repository Setup Guide

This guide explains how to configure the Traccar Docker deployment to use your private Traccar repositories (backend and frontend) instead of the public ones.

## Quick Setup

### 1. Update your `.env` file:
```bash
# Private Repository Configuration
GIT_USERNAME=your-github-username
GIT_PASSWORD=your-personal-access-token
GIT_BACKEND_REPO_URL=https://github.com/your-username/your-private-traccar.git
GIT_FRONTEND_REPO_URL=https://github.com/your-username/your-private-traccar-web.git
```

### 2. Build and run:
```bash
docker compose up -d --build
```

## Security Methods

### Method 1: Personal Access Token (Recommended)
**GitHub/GitLab Personal Access Token**

1. Create a Personal Access Token:
   - GitHub: Settings → Developer settings → Personal access tokens
   - GitLab: User Settings → Access Tokens
   
2. Set permissions: `repo` (full repository access)

3. Use in `.env`:
```bash
GIT_USERNAME=your-username
GIT_PASSWORD=ghp_your_personal_access_token
GIT_BACKEND_REPO_URL=https://github.com/your-username/your-private-traccar.git
GIT_FRONTEND_REPO_URL=https://github.com/your-username/your-private-traccar-web.git
```

### Method 2: SSH Keys (Advanced)
For SSH authentication, you can modify the Dockerfile to use SSH keys instead of HTTPS credentials.

1. Generate SSH key: `ssh-keygen -t rsa -b 4096`
2. Add public key to your Git provider  
3. Use SSH clone URL: `git@github.com:user/repo.git`
4. Mount SSH key as Docker secret during build

### Method 3: Local Source Copy
If you have the source code locally:

1. Copy your Traccar source to `./traccar-source/`
2. Modify Dockerfile to use: `COPY ./traccar-source/ .`
3. No credentials needed

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GIT_USERNAME` | Git username or token name | `john_doe` |
| `GIT_PASSWORD` | Password, token, or SSH key | `ghp_abc123...` |
| `GIT_BACKEND_REPO_URL` | Backend repository URL | `https://github.com/user/traccar.git` |
| `GIT_FRONTEND_REPO_URL` | Frontend repository URL | `https://github.com/user/traccar-web.git` |

## Git Provider Examples

### GitHub
```bash
GIT_USERNAME=your-username
GIT_PASSWORD=ghp_1234567890abcdef...
GIT_BACKEND_REPO_URL=https://github.com/your-username/traccar-private.git
GIT_FRONTEND_REPO_URL=https://github.com/your-username/traccar-web-private.git
```

### GitLab
```bash
GIT_USERNAME=your-username  
GIT_PASSWORD=glpat-xxxxxxxxxxxx
GIT_BACKEND_REPO_URL=https://gitlab.com/your-username/traccar-private.git
GIT_FRONTEND_REPO_URL=https://gitlab.com/your-username/traccar-web-private.git
```

### Bitbucket
```bash
GIT_USERNAME=your-username
GIT_PASSWORD=your-app-password
GIT_BACKEND_REPO_URL=https://bitbucket.org/your-username/traccar-private.git
GIT_FRONTEND_REPO_URL=https://bitbucket.org/your-username/traccar-web-private.git
```

### Self-hosted Git
```bash
GIT_USERNAME=your-username
GIT_PASSWORD=your-token
GIT_BACKEND_REPO_URL=https://git.yourcompany.com/team/traccar-private.git
GIT_FRONTEND_REPO_URL=https://git.yourcompany.com/team/traccar-web-private.git
```

## Build Arguments

You can also pass build arguments directly:

```bash
docker build \
  --build-arg GIT_USERNAME=your-username \
  --build-arg GIT_PASSWORD=your-token \
  --build-arg GIT_BACKEND_REPO_URL=https://github.com/user/traccar.git \
  --build-arg GIT_FRONTEND_REPO_URL=https://github.com/user/traccar-web.git \
  -f Dockerfile.backend \
  -t traccar-backend .
```

## Security Best Practices

1. **Use Personal Access Tokens** instead of passwords
2. **Limit token permissions** to only repository access
3. **Rotate tokens regularly** (every 6-12 months)
4. **Never commit credentials** to version control
5. **Use environment files** with restricted permissions: `chmod 600 .env`
6. **Consider SSH keys** for production environments

## Troubleshooting

### Authentication Failed
- Verify username/token is correct
- Check token permissions include repository access
- Ensure repository URL is correct

### Repository Not Found
- Verify repository exists and you have access
- Check if repository URL format is correct
- Ensure token has permission to access private repos

### Build Fails
- Check if your private repository has the expected structure
- Verify gradle build works in your private repo
- Check for missing dependencies or build configurations

## Production Considerations

For production deployments:

1. **Use dedicated service accounts** with minimal permissions
2. **Store credentials in secure secret management**
3. **Consider using SSH keys** with restricted access
4. **Monitor access logs** for unauthorized attempts
5. **Use least-privilege principle** for repository access

## Fallback to Public Repository

To revert to the public Traccar repository:

```bash
# Remove or comment out in .env:
# GIT_USERNAME=
# GIT_PASSWORD=
# GIT_BACKEND_REPO_URL=
# GIT_FRONTEND_REPO_URL=
```

Or set explicitly:
```bash
GIT_BACKEND_REPO_URL=https://github.com/traccar/traccar.git
GIT_FRONTEND_REPO_URL=https://github.com/traccar/traccar-web.git
```
