# GitOps Multi-Web Hosting Platform

A comprehensive GitOps-based solution for hosting multiple websites on one or more virtual machines with Traefik reverse proxy, automatic Let's Encrypt SSL certificates, and secure customer access for backups.

## Features

- 🔒 **Automatic SSL/TLS**: Let's Encrypt certificates with automatic renewal via Traefik
- 🚀 **Traefik Reverse Proxy**: Modern HTTP reverse proxy and load balancer
- 🔐 **Security & Isolation**: Docker-based isolation for each website
- 📦 **Multiple Website Types**: Support for WordPress, static sites, and Node.js applications
- 💾 **Automated Backups**: Scripts for backing up websites and databases
- 👥 **Customer Access**: SFTP server for secure backup downloads
- 📊 **Traefik Dashboard**: Monitor and manage your infrastructure
- 🎯 **GitOps Ready**: Version-controlled infrastructure as code

## Architecture

```
┌─────────────────────────────────────────────┐
│           Internet (HTTPS/HTTP)             │
└────────────────┬────────────────────────────┘
                 │
         ┌───────▼────────┐
         │    Traefik     │  (Reverse Proxy + SSL)
         │   Port 80/443  │
         └───────┬────────┘
                 │
     ┌───────────┼───────────────┐
     │           │               │
┌────▼────┐ ┌───▼────┐  ┌──────▼──────┐
│WordPress│ │ Static │  │   Node.js   │
│  Site   │ │  Site  │  │     App     │
└────┬────┘ └────────┘  └─────────────┘
     │
┌────▼────┐
│  MySQL  │
└─────────┘
```

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Domain name(s) pointed to your server
- Cloudflare account (for DNS challenge)

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/benk79hes/gitops.git
   cd gitops
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   Update with your:
   - Domain name
   - Cloudflare API credentials
   - Traefik dashboard password

3. **Set up Traefik**
   ```bash
   # Ensure acme.json has correct permissions
   chmod 600 traefik-config/acme.json
   
   # Start Traefik
   docker-compose up -d
   ```

4. **Verify Traefik is running**
   ```bash
   docker ps
   docker logs traefik
   ```

## Deploying Websites

### WordPress Site

1. **Copy the example configuration**
   ```bash
   cp -r sites/example-wordpress sites/mysite-wordpress
   cd sites/mysite-wordpress
   ```

2. **Configure the site**
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   Update:
   - `SITE_NAME`: Unique identifier (e.g., `mysite-wp`)
   - `SITE_DOMAIN`: Your domain (e.g., `mysite.com`)
   - Database credentials

3. **Deploy**
   ```bash
   docker-compose up -d
   ```

4. **Access your site**
   - Website: `https://mysite.com`
   - phpMyAdmin: `https://pma.mysite.com`

### Static Site

1. **Copy the example**
   ```bash
   cp -r sites/example-static sites/mysite-static
   cd sites/mysite-static
   ```

2. **Configure**
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Add your content**
   ```bash
   # Place your HTML files in html/ directory
   cp -r /path/to/your/site/* html/
   ```

4. **Deploy**
   ```bash
   docker-compose up -d
   ```

### Node.js Application

1. **Copy the example**
   ```bash
   cp -r sites/example-nodejs sites/myapp-nodejs
   cd sites/myapp-nodejs
   ```

2. **Configure**
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Add your application code**
   ```bash
   # Replace index.js and package.json with your app
   ```

4. **Deploy**
   ```bash
   docker-compose up -d
   ```

## Backup & Restore

### Backup a Site

```bash
./scripts/backup-site.sh <site-name>

# Example
./scripts/backup-site.sh mysite-wp
```

This creates:
- Compressed website files
- Database dump (if applicable)
- Metadata file

Backups are stored in `backups/<site-name>/` and kept for 30 days.

### Restore a Site

```bash
./scripts/restore-site.sh <site-name> <backup-timestamp>

# Example
./scripts/restore-site.sh mysite-wp 20250115_120000
```

### List Available Backups

```bash
ls -lh backups/<site-name>/
```

## Customer Access to Backups

The platform includes an SFTP server for customers to securely download their backups.

### Setup SFTP Access

1. **Configure SFTP users**
   ```bash
   cd customer-access
   cp sftp-users.conf.example sftp-users.conf
   nano sftp-users.conf
   ```

2. **Add a customer**
   ```
   customer1:secure_password::1001:/home/backups/mysite-wp
   ```

3. **Start SFTP server**
   ```bash
   docker-compose up -d
   ```

### Customer Connection

Customers can connect via SFTP:
```bash
sftp -P 2222 customer1@your-server.com
```

Or using FileZilla:
- Host: `your-server.com`
- Port: `2222`
- Protocol: `SFTP`
- Username: `customer1`
- Password: `[as configured]`

## Security Features

### Isolation
- Each website runs in its own Docker container
- Internal networks isolate database from external access
- Read-only backup access for customers

### SSL/TLS
- Automatic Let's Encrypt certificates
- HTTPS redirection enforced
- Security headers applied (HSTS, X-Frame-Options, etc.)

### Rate Limiting
- Built-in rate limiting middleware
- DDoS protection via Traefik

### Access Control
- Traefik dashboard protected with basic auth
- Database admin interfaces on separate subdomains
- SFTP access limited to specific backup directories

## Monitoring

### Traefik Dashboard

Access the dashboard at `https://traefik-dashboard.yourdomain.com`

### Logs

```bash
# Traefik logs
tail -f logs/traefik/traefik.log
tail -f logs/traefik/access.log

# Container logs
docker logs <container-name>
docker logs -f mysite-wp_wordpress
```

## Maintenance

### Update Traefik

```bash
docker-compose pull
docker-compose up -d
```

### Update a Website

```bash
cd sites/mysite-wordpress
docker-compose pull
docker-compose up -d
```

### Clean Up Old Backups

Backups older than 30 days are automatically removed by the backup script.

Manual cleanup:
```bash
find backups/ -name "backup_*" -type f -mtime +30 -delete
```

## Scaling to Multiple Servers

This setup can be extended to multiple servers:

1. **Deploy Traefik on edge servers**
2. **Use Docker Swarm or Kubernetes** for orchestration
3. **Implement shared storage** for backups (NFS, S3, etc.)
4. **Add load balancing** between edge servers

## Directory Structure

```
gitops/
├── docker-compose.yml          # Main Traefik setup
├── .env.example               # Environment template
├── traefik-config/
│   ├── traefik.yml           # Traefik configuration
│   ├── config.yml            # Middleware & routing rules
│   └── acme.json             # SSL certificates storage
├── sites/
│   ├── example-wordpress/    # WordPress template
│   ├── example-static/       # Static site template
│   └── example-nodejs/       # Node.js app template
├── scripts/
│   ├── backup-site.sh        # Backup script
│   └── restore-site.sh       # Restore script
├── backups/                  # Backup storage
├── customer-access/          # SFTP server for customers
└── logs/                     # Application logs
```

## Troubleshooting

### Certificate Issues

```bash
# Check certificate status
docker logs traefik | grep -i certificate

# Force certificate renewal
rm traefik-config/acme.json
touch traefik-config/acme.json
chmod 600 traefik-config/acme.json
docker-compose restart
```

### Container Won't Start

```bash
# Check container logs
docker logs <container-name>

# Check Docker network
docker network ls
docker network inspect web

# Verify environment variables
cd sites/your-site
cat .env
```

### SFTP Access Issues

```bash
# Check SFTP container
docker logs customer_sftp

# Verify user configuration
cd customer-access
cat sftp-users.conf

# Test connection locally
sftp -P 2222 username@localhost
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

This project is open source and available under the MIT License.

## Support

For issues or questions:
- Open an issue on GitHub
- Check the documentation in each example site directory
- Review Traefik documentation: https://doc.traefik.io/traefik/

## Acknowledgments

- [Traefik](https://traefik.io/) - Modern HTTP reverse proxy
- [Let's Encrypt](https://letsencrypt.org/) - Free SSL certificates
- [Docker](https://www.docker.com/) - Containerization platform