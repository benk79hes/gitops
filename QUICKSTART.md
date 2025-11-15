# Quick Start Guide

Get your GitOps multi-web hosting platform running in minutes!

## Prerequisites

- Server with Ubuntu 20.04+ (or similar Linux distribution)
- Docker and Docker Compose installed
- Domain name(s) pointing to your server
- Cloudflare account (free tier works)

## 5-Minute Setup

### 1. Install Docker (if not already installed)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

Log out and back in for the group change to take effect.

### 2. Clone the Repository

```bash
git clone https://github.com/benk79hes/gitops.git
cd gitops
```

### 3. Run Setup Script

```bash
./setup.sh
```

This will:
- Create necessary directories
- Set up SSL certificate storage
- Create environment file template
- Set up Docker network

### 4. Configure Environment

Edit `.env` file:

```bash
nano .env
```

Update these values:
```bash
DOMAIN=yourdomain.com
CF_API_EMAIL=your-email@example.com
CF_DNS_API_TOKEN=your-cloudflare-token
TRAEFIK_DASHBOARD_AUTH=admin:$$apr1$$...
```

**Get Cloudflare API Token:**
1. Log in to Cloudflare dashboard
2. Go to "My Profile" > "API Tokens"
3. Create token with "Edit zone DNS" permissions
4. Copy the token

**Generate Dashboard Password:**
```bash
sudo apt-get install -y apache2-utils
echo $(htpasswd -nb admin your-password) | sed -e s/\\$/\\$\\$/g
```

### 5. Start Traefik

```bash
docker-compose up -d
```

Check if it's running:
```bash
docker ps
docker logs traefik
```

### 6. Deploy Your First Website

**Option A: WordPress Site**
```bash
./scripts/deploy-site.sh wordpress mysite mysite.com
cd sites/mysite
docker-compose up -d
```

**Option B: Static Site**
```bash
./scripts/deploy-site.sh static mysite mysite.com
cd sites/mysite
# Add your HTML files to html/ directory
docker-compose up -d
```

**Option C: Node.js App**
```bash
./scripts/deploy-site.sh nodejs myapp app.mysite.com
cd sites/myapp
# Add your application code
docker-compose up -d
```

### 7. Verify

Visit your domain: `https://mysite.com`

Your site should be live with automatic SSL!

## Common Commands

```bash
# View all sites
./scripts/list-sites.sh

# Backup a site
./scripts/backup-site.sh mysite

# View logs
docker logs traefik
docker logs mysite_wordpress

# Stop a site
cd sites/mysite
docker-compose down

# Start a site
cd sites/mysite
docker-compose up -d

# Update all containers
docker-compose pull
docker-compose up -d
```

## Using Makefile

For easier management:

```bash
# Start Traefik
make start

# Deploy new site
make deploy-site TEMPLATE=wordpress NAME=site2 DOMAIN=site2.com

# List all sites
make list-sites

# Backup a site
make backup SITE=mysite

# View status
make status

# See all commands
make help
```

## Next Steps

1. **Set up backups:**
   - Create cron job for automated backups
   - Configure customer SFTP access
   - Test restore procedure

2. **Secure your setup:**
   - Review SECURITY.md
   - Enable firewall
   - Set up monitoring
   - Enable 2FA where possible

3. **Monitor your infrastructure:**
   - Access Traefik dashboard
   - Review logs regularly
   - Set up alerts

4. **Scale as needed:**
   - Add more sites
   - Optimize resources
   - Add monitoring tools

## Troubleshooting

If something goes wrong, see **TROUBLESHOOTING.md** for solutions to common issues.

### Quick Checks

```bash
# Is Docker running?
docker ps

# Is Traefik running?
docker logs traefik

# Are ports accessible?
sudo netstat -tlnp | grep -E ':(80|443|2222)'

# Check DNS
nslookup mysite.com

# Test SSL
curl -I https://mysite.com
```

## Getting Help

- Check **README.md** for detailed documentation
- See **TROUBLESHOOTING.md** for common issues
- Review **SECURITY.md** for security best practices
- Open an issue on GitHub

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Cloudflare API](https://api.cloudflare.com/)
- [Let's Encrypt](https://letsencrypt.org/)

---

**Enjoy your new hosting platform! 🚀**
