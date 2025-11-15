# Security & Isolation Guide

This guide explains the security features and isolation mechanisms in the GitOps platform.

## Security Features Overview

### 1. Container Isolation

Each website runs in its own Docker container with:
- Isolated file systems
- Separate networks
- Resource limits
- No direct internet access (unless needed)

### 2. Network Segmentation

```
web network (external)
├── Traefik (only entry point)
└── Website containers (port 80/443 only)

internal network (per-site)
├── Website container
└── Database container (not exposed)
```

Databases are **never** exposed to the internet.

### 3. SSL/TLS Encryption

- Automatic Let's Encrypt certificates
- TLS 1.2+ only
- HTTPS redirection enforced
- HSTS headers enabled

### 4. Security Headers

Applied automatically via Traefik:
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000`

### 5. Rate Limiting

Built-in rate limiting:
- 100 requests per minute per IP
- 50 burst capacity
- Applied to all routes

## Best Practices

### Container Security

1. **Run as non-root user**
   ```yaml
   services:
     app:
       user: "1000:1000"
   ```

2. **Read-only root filesystem**
   ```yaml
   services:
     app:
       read_only: true
       tmpfs:
         - /tmp
   ```

3. **Limit resources**
   ```yaml
   services:
     app:
       deploy:
         resources:
           limits:
             cpus: '0.5'
             memory: 512M
   ```

### Database Security

1. **Never expose database ports** to the internet
2. **Use strong passwords** (32+ characters)
3. **Regular backups** with encryption
4. **Separate credentials** per site

### Backup Security

1. **Encrypt backups**
   ```bash
   tar -czf - data/ | gpg -c > backup.tar.gz.gpg
   ```

2. **Secure SFTP access**
   - Use SSH keys instead of passwords
   - Limit access to specific directories
   - Regular audit of access logs

3. **Backup retention policy**
   - Keep 30 days of backups
   - Rotate old backups automatically

## Access Control

### Traefik Dashboard

Protected with HTTP Basic Auth:

```bash
# Generate password hash
echo $(htpasswd -nb admin your-password) | sed -e s/\\$/\\$\\$/g
```

Update in `.env`:
```bash
TRAEFIK_DASHBOARD_AUTH=admin:$$apr1$$...
```

### Database Admin (phpMyAdmin)

Accessible only via:
- Subdomain (e.g., `pma.example.com`)
- HTTPS only
- Recommended: Add IP whitelist

Add IP restriction:
```yaml
labels:
  - "traefik.http.middlewares.pma-ipwhitelist.ipwhitelist.sourcerange=1.2.3.4/32"
  - "traefik.http.routers.${SITE_NAME}-pma-secure.middlewares=pma-ipwhitelist"
```

### Customer SFTP Access

Isolated per customer:

```
customer-access/
└── sftp-users.conf
    customer1:password::1001:/home/backups/site1
    customer2:password::1002:/home/backups/site2
```

Each customer can only access their own backups.

## Hardening Checklist

### Server Level
- [ ] Enable firewall (UFW/iptables)
- [ ] Install fail2ban
- [ ] Disable root SSH login
- [ ] Use SSH keys only
- [ ] Keep system updated
- [ ] Enable automatic security updates

### Docker Level
- [ ] Use official images only
- [ ] Pin image versions
- [ ] Regular image updates
- [ ] Enable Docker Content Trust
- [ ] Use secrets for sensitive data

### Application Level
- [ ] Strong passwords everywhere
- [ ] Enable 2FA where possible
- [ ] Regular security updates
- [ ] Monitor logs for suspicious activity
- [ ] Implement backups and test restores

### Network Level
- [ ] Close unused ports
- [ ] Enable DDoS protection (Cloudflare)
- [ ] Use VPN for admin access
- [ ] Monitor traffic patterns

## Monitoring & Logging

### Log Files

```bash
# Traefik access logs
tail -f logs/traefik/access.log

# Traefik error logs
tail -f logs/traefik/traefik.log

# Container logs
docker logs -f container_name
```

### Security Monitoring

Monitor for:
- Failed login attempts
- Unusual traffic patterns
- High resource usage
- Database connection errors
- SSL certificate expiration

### Automated Alerts

Set up alerts for:
```bash
# Example: Check SSL expiration
*/0 12 * * * certbot certificates | mail -s "SSL Status" admin@example.com
```

## Incident Response

### Compromised Container

1. **Isolate immediately**
   ```bash
   docker-compose down
   docker network disconnect web container_name
   ```

2. **Analyze logs**
   ```bash
   docker logs container_name > incident.log
   ```

3. **Restore from clean backup**
   ```bash
   ./scripts/restore-site.sh sitename backup_timestamp
   ```

4. **Update and harden**
   - Change all passwords
   - Update all software
   - Review security settings

### Database Breach

1. **Stop database access**
   ```bash
   docker-compose stop db
   ```

2. **Change all passwords**
3. **Audit database users**
4. **Restore from backup if needed**
5. **Review access logs**

## Security Updates

### Weekly Tasks
- Review logs for suspicious activity
- Check for software updates
- Verify backups are working

### Monthly Tasks
- Update all containers
- Review and rotate passwords
- Audit user access
- Test backup restoration

### Quarterly Tasks
- Full security audit
- Penetration testing
- Review and update security policies
- Disaster recovery drill

## Compliance

### GDPR Considerations

- Encrypt customer data
- Implement data retention policies
- Provide data export capabilities
- Secure data deletion procedures

### Data Protection

- Regular backups (daily recommended)
- Backup encryption
- Secure backup storage
- Tested restoration procedures

## Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Traefik Security Documentation](https://doc.traefik.io/traefik/https/acme/)
