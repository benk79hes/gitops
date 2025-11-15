# WordPress Site Deployment Guide

This guide explains how to deploy and manage WordPress sites in the GitOps platform.

## Features

- WordPress latest version
- MySQL/MariaDB database
- phpMyAdmin for database management
- Automatic SSL certificates
- Isolated environment

## Quick Deploy

```bash
# Using the deploy script
./scripts/deploy-site.sh wordpress mysite mysite.com

# Or manually
cp -r sites/example-wordpress sites/mysite
cd sites/mysite
cp .env.example .env
nano .env  # Configure your settings
docker-compose up -d
```

## Environment Variables

Edit `.env` file:

```bash
# Unique site identifier
SITE_NAME=mysite

# Your domain
SITE_DOMAIN=mysite.com

# Database configuration
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=secure_password_here
DB_ROOT_PASSWORD=root_password_here
```

## First-Time WordPress Setup

1. Visit `https://mysite.com`
2. Complete WordPress installation wizard
3. Choose language
4. Create admin user
5. Start building your site!

## Database Management

Access phpMyAdmin at `https://pma.mysite.com`

**Login credentials:**
- Server: `db`
- Username: `root`
- Password: Your `DB_ROOT_PASSWORD` from `.env`

## File Management

WordPress files are stored in `./wordpress-data/`

```bash
# Access WordPress files
cd wordpress-data/

# Install plugins manually
cd wordpress-data/wp-content/plugins/
# Copy plugin files here

# Install themes manually
cd wordpress-data/wp-content/themes/
# Copy theme files here
```

## Common Tasks

### Update WordPress Core

```bash
cd sites/mysite
docker-compose pull wordpress
docker-compose up -d
```

### Install WP-CLI

Add to docker-compose.yml:

```yaml
  wpcli:
    image: wordpress:cli
    volumes:
      - ./wordpress-data:/var/www/html
    depends_on:
      - db
      - wordpress
```

Use it:

```bash
docker-compose run --rm wpcli wp plugin list
docker-compose run --rm wpcli wp theme list
```

### Change PHP Settings

Create `uploads.ini`:

```ini
file_uploads = On
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
```

Add to docker-compose.yml volumes:

```yaml
volumes:
  - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
```

## Backup & Restore

### Create Backup

```bash
../scripts/backup-site.sh mysite
```

### Restore Backup

```bash
../scripts/restore-site.sh mysite 20250115_120000
```

## Troubleshooting

### White Screen of Death

```bash
# Enable WordPress debug mode
cd wordpress-data
nano wp-config.php

# Add these lines:
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

# Check logs
tail -f wordpress-data/wp-content/debug.log
```

### Database Connection Error

```bash
# Verify database is running
docker-compose ps

# Check database logs
docker-compose logs db

# Verify credentials in .env
cat .env
```

### Permission Issues

```bash
# Fix WordPress file permissions
docker-compose exec wordpress chown -R www-data:www-data /var/www/html
```

## Performance Optimization

### Enable OPcache

Add to docker-compose.yml:

```yaml
environment:
  PHP_OPCACHE_ENABLE: 1
  PHP_OPCACHE_MEMORY_CONSUMPTION: 128
```

### Use Redis for Object Caching

Add Redis service:

```yaml
  redis:
    image: redis:alpine
    container_name: ${SITE_NAME}_redis
    restart: unless-stopped
    networks:
      - internal
```

Install Redis Object Cache plugin in WordPress.

## Security Tips

1. **Use strong passwords** for database and WordPress admin
2. **Keep WordPress updated** regularly
3. **Use security plugins** like Wordfence or Sucuri
4. **Limit login attempts**
5. **Enable 2FA** for admin users
6. **Regular backups** - automate with cron
7. **Monitor logs** for suspicious activity

## Migration from Existing WordPress

1. Export database from old site
2. Copy WordPress files
3. Deploy new site
4. Import database via phpMyAdmin
5. Update `wp-config.php` if needed
6. Update site URL in WordPress settings

## Resources

- [WordPress Documentation](https://wordpress.org/support/)
- [WordPress Codex](https://codex.wordpress.org/)
- [WordPress CLI](https://wp-cli.org/)
