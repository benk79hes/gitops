# Troubleshooting Guide

Common issues and solutions for the GitOps Multi-Web Hosting Platform.

## Traefik Issues

### Traefik Won't Start

**Symptom:** `docker-compose up -d` fails or Traefik container exits immediately.

**Solutions:**

1. Check acme.json permissions:
   ```bash
   chmod 600 traefik-config/acme.json
   ```

2. Verify .env configuration:
   ```bash
   cat .env
   # Ensure CF_API_EMAIL and CF_DNS_API_TOKEN are set
   ```

3. Check Traefik logs:
   ```bash
   docker logs traefik
   ```

4. Validate docker-compose.yml:
   ```bash
   docker-compose config
   ```

### SSL Certificate Not Issued

**Symptom:** Website shows SSL error or "certificate not trusted".

**Solutions:**

1. Check Traefik logs for certificate errors:
   ```bash
   docker logs traefik | grep -i certificate
   ```

2. Verify DNS is pointing to your server:
   ```bash
   nslookup yourdomain.com
   ```

3. Check Cloudflare API credentials:
   ```bash
   # Test Cloudflare API
   curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

4. Clear acme.json and retry:
   ```bash
   docker-compose down
   rm traefik-config/acme.json
   touch traefik-config/acme.json
   chmod 600 traefik-config/acme.json
   docker-compose up -d
   ```

### Traefik Dashboard Not Accessible

**Symptom:** Cannot access dashboard at traefik-dashboard.domain.com

**Solutions:**

1. Verify DNS record exists for traefik-dashboard subdomain

2. Check dashboard authentication:
   ```bash
   # Generate new password
   echo $(htpasswd -nb admin newpassword) | sed -e s/\\$/\\$\\$/g
   # Update in .env
   ```

3. Verify Traefik is running:
   ```bash
   docker ps | grep traefik
   ```

## Website Issues

### 404 Not Found

**Symptom:** Website returns 404 error.

**Solutions:**

1. Check if container is running:
   ```bash
   cd sites/your-site
   docker-compose ps
   ```

2. Verify Traefik labels:
   ```bash
   docker inspect your-site_container | grep -A 20 Labels
   ```

3. Check Traefik routing:
   - Access Traefik dashboard
   - Verify router exists for your domain

4. Test DNS resolution:
   ```bash
   nslookup yourdomain.com
   ```

### 502 Bad Gateway

**Symptom:** Website shows "502 Bad Gateway" error.

**Solutions:**

1. Check if backend container is running:
   ```bash
   docker-compose ps
   ```

2. Start the container if stopped:
   ```bash
   docker-compose up -d
   ```

3. Check container logs:
   ```bash
   docker-compose logs
   ```

4. Verify container is on web network:
   ```bash
   docker inspect your-site_container | grep -A 10 Networks
   ```

### Website Slow or Unresponsive

**Solutions:**

1. Check container resource usage:
   ```bash
   docker stats
   ```

2. Check Docker logs for errors:
   ```bash
   docker-compose logs --tail=100
   ```

3. Restart the containers:
   ```bash
   cd sites/your-site
   docker-compose restart
   ```

4. Check disk space:
   ```bash
   df -h
   ```

## Database Issues

### Cannot Connect to Database

**Symptom:** Website shows "Error establishing database connection".

**Solutions:**

1. Verify database container is running:
   ```bash
   docker-compose ps db
   ```

2. Check database logs:
   ```bash
   docker-compose logs db
   ```

3. Verify credentials in .env:
   ```bash
   cat .env
   ```

4. Test database connection:
   ```bash
   docker exec -it sitename_db mysql -u root -p
   ```

### Database Data Lost

**Solutions:**

1. Restore from backup:
   ```bash
   ./scripts/restore-site.sh sitename timestamp
   ```

2. Check volume mounts:
   ```bash
   docker volume ls
   docker volume inspect sitename_db-data
   ```

## Backup Issues

### Backup Script Fails

**Solutions:**

1. Check script has execute permissions:
   ```bash
   chmod +x scripts/backup-site.sh
   ```

2. Verify site directory exists:
   ```bash
   ls -la sites/sitename
   ```

3. Check disk space:
   ```bash
   df -h backups/
   ```

4. Manually run with verbose output:
   ```bash
   bash -x scripts/backup-site.sh sitename
   ```

### Cannot Restore Backup

**Solutions:**

1. Verify backup files exist:
   ```bash
   ls -lh backups/sitename/
   ```

2. Check backup file integrity:
   ```bash
   tar -tzf backup_file.tar.gz
   ```

3. Ensure containers are stopped before restore:
   ```bash
   cd sites/sitename
   docker-compose down
   ```

## SFTP Access Issues

### Cannot Connect to SFTP

**Symptom:** SFTP connection refused or authentication failed.

**Solutions:**

1. Check SFTP container is running:
   ```bash
   docker ps | grep sftp
   ```

2. Verify port 2222 is accessible:
   ```bash
   netstat -tlnp | grep 2222
   ```

3. Check firewall rules:
   ```bash
   sudo ufw status
   ```

4. Verify user configuration:
   ```bash
   cd customer-access
   cat sftp-users.conf
   ```

### Customer Can Access Wrong Directory

**Solutions:**

1. Check user configuration in sftp-users.conf
2. Ensure correct home directory is set
3. Restart SFTP container:
   ```bash
   cd customer-access
   docker-compose restart
   ```

## Network Issues

### Containers Cannot Communicate

**Solutions:**

1. Check Docker networks:
   ```bash
   docker network ls
   docker network inspect web
   ```

2. Recreate web network:
   ```bash
   docker network rm web
   docker network create web
   docker-compose restart
   ```

3. Verify network configuration in docker-compose.yml

### Port Already in Use

**Symptom:** Error: "port is already allocated".

**Solutions:**

1. Check what's using the port:
   ```bash
   sudo lsof -i :80
   sudo lsof -i :443
   ```

2. Stop conflicting service:
   ```bash
   sudo systemctl stop apache2  # or nginx
   ```

3. Change port in docker-compose.yml if needed

## Performance Issues

### High CPU Usage

**Solutions:**

1. Check which container is using CPU:
   ```bash
   docker stats
   ```

2. Limit container resources:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
   ```

3. Check for infinite loops in application logs

### High Memory Usage

**Solutions:**

1. Add memory limits:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 512M
   ```

2. Increase server memory
3. Optimize application configuration

### Disk Full

**Solutions:**

1. Clean up Docker:
   ```bash
   docker system prune -a
   ```

2. Remove old backups:
   ```bash
   find backups/ -mtime +30 -delete
   ```

3. Clean up logs:
   ```bash
   truncate -s 0 logs/traefik/*.log
   ```

## General Debugging

### Check All Services Status

```bash
# Traefik
docker ps | grep traefik
docker logs traefik --tail=50

# All sites
./scripts/list-sites.sh

# Docker networks
docker network ls
docker network inspect web

# Disk space
df -h

# Memory usage
free -h
```

### Restart Everything

```bash
# Stop all sites
for site in sites/*; do
  if [ -f "$site/docker-compose.yml" ]; then
    cd "$site"
    docker-compose down
    cd ../..
  fi
done

# Restart Traefik
docker-compose restart

# Start sites again
for site in sites/*; do
  if [ -f "$site/docker-compose.yml" ] && [[ ! $site == *"example"* ]]; then
    cd "$site"
    docker-compose up -d
    cd ../..
  fi
done
```

### Get Support

If issues persist:

1. Collect logs:
   ```bash
   docker logs traefik > traefik.log
   docker-compose -f sites/sitename/docker-compose.yml logs > site.log
   ```

2. Check system info:
   ```bash
   docker version
   docker-compose version
   uname -a
   df -h
   free -h
   ```

3. Open an issue on GitHub with:
   - Description of the problem
   - Steps to reproduce
   - Relevant logs
   - System information

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Cloudflare API Documentation](https://api.cloudflare.com/)
