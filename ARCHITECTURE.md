# Architecture & Design

This document describes the architecture and design decisions of the GitOps Multi-Web Hosting Platform.

## Overview

The platform is designed as a Docker-based infrastructure with Traefik as the central reverse proxy, enabling multiple isolated websites to run on one or more virtual machines with automatic SSL/TLS certificates from Let's Encrypt.

## Core Components

### 1. Traefik Reverse Proxy

**Role:** Central entry point for all HTTP/HTTPS traffic

**Features:**
- Automatic service discovery via Docker labels
- Let's Encrypt SSL certificate management
- HTTP to HTTPS redirection
- Load balancing
- Rate limiting
- Security headers injection

**Why Traefik:**
- Native Docker integration
- Automatic SSL with Let's Encrypt
- Dynamic configuration
- Built-in dashboard
- Zero-downtime deployments

### 2. Docker Networks

**web (external):** 
- Public-facing network
- Connects Traefik to website containers
- Only HTTP/HTTPS traffic

**internal (per-site):**
- Private network for each site
- Connects website to database
- Not accessible from internet
- Isolated between sites

**Benefits:**
- Network segmentation
- Security isolation
- Prevents cross-site access
- Database protection

### 3. Site Templates

#### WordPress Template
```
WordPress Container (PHP/Apache)
    ↓
MariaDB Container (Database)
    ↓
phpMyAdmin Container (Management)
```

**Isolation:**
- Separate database per site
- Unique credentials per site
- Isolated file system
- Private internal network

#### Static Site Template
```
Nginx Container (Web Server)
    ↓
HTML/CSS/JS Files (Volume Mount)
```

**Benefits:**
- Minimal resource usage
- Fast performance
- Simple deployment
- Easy updates

#### Node.js Template
```
Node.js Container (Custom Build)
    ↓
Application Code
    ↓
Optional: Database Container
```

**Flexibility:**
- Custom Dockerfile
- Any Node.js framework
- Environment variables
- Database integration

### 4. Backup System

**Components:**
- Backup scripts (automated)
- Scheduled tasks (cron)
- Compressed archives
- 30-day retention

**What's Backed Up:**
- Website files
- Database dumps
- Configuration files
- Metadata

**Storage:**
- Local filesystem
- Can be extended to S3, NFS, etc.

### 5. Customer Access (SFTP)

**Purpose:** Secure file access for customers

**Features:**
- Read-only access to backups
- User isolation
- Chrooted environment
- SSH key support

**Security:**
- No write access
- Directory restrictions
- Separate credentials per customer
- Audit logging

## Traffic Flow

```
Internet
    ↓
Port 80/443
    ↓
Traefik (SSL Termination)
    ↓
Host Header Routing
    ↓
    ├── domain1.com → Site 1 Container
    ├── domain2.com → Site 2 Container
    └── domainN.com → Site N Container
```

## SSL/TLS Certificate Flow

```
Traefik detects new service
    ↓
Reads domain from labels
    ↓
Checks acme.json for certificate
    ↓
If not found:
    ├── Initiates DNS-01 challenge
    ├── Updates Cloudflare DNS TXT record
    ├── Let's Encrypt validates
    ├── Certificate issued
    └── Saved to acme.json
    ↓
Certificate served for HTTPS
    ↓
Auto-renewal before expiry
```

## Security Architecture

### Layers of Security

1. **Network Layer**
   - Firewall rules
   - Port restrictions
   - DDoS protection (Cloudflare)

2. **Container Layer**
   - Isolation via Docker
   - Resource limits
   - Read-only file systems (where applicable)
   - No new privileges

3. **Application Layer**
   - Security headers
   - Rate limiting
   - Authentication
   - Input validation

4. **Data Layer**
   - Database isolation
   - Encrypted backups
   - Secure credentials
   - Access control

### Attack Surface Reduction

- Databases not exposed to internet
- Admin interfaces on subdomains
- SFTP on non-standard port
- Minimal attack vectors
- Regular updates

## Scalability

### Vertical Scaling
- Increase server resources
- More CPU/RAM for containers
- Larger storage

### Horizontal Scaling

**Single Server → Multiple Servers:**

```
Load Balancer (External)
    ↓
    ├── Server 1 (Traefik + Sites)
    ├── Server 2 (Traefik + Sites)
    └── Server N (Traefik + Sites)
    ↓
Shared Storage (NFS/S3)
    ├── Website Files
    ├── Backups
    └── Logs
```

**Migration Path:**
1. Deploy Traefik on multiple servers
2. Use Docker Swarm or Kubernetes
3. Implement shared storage
4. Add external load balancer
5. Configure database clustering

## GitOps Workflow

### Infrastructure as Code

All configuration in Git:
- Docker Compose files
- Traefik configuration
- Site templates
- Management scripts

### Deployment Process

```
1. Commit changes to Git
2. Pull changes on server
3. Run deployment script
4. Docker pulls images
5. Containers restart
6. Traefik detects changes
7. Traffic routes to new version
```

### Benefits
- Version control
- Audit trail
- Easy rollback
- Reproducible environments
- Team collaboration

## Monitoring & Observability

### Current Implementation
- Traefik access logs
- Application logs
- Docker stats
- Health checks

### Future Enhancements
- Prometheus metrics
- Grafana dashboards
- Alerting (AlertManager)
- Log aggregation (ELK stack)
- Uptime monitoring

## Backup Strategy

### 3-2-1 Backup Rule

**3 Copies:**
- Production data (live)
- Local backup (on server)
- Remote backup (offsite)

**2 Media Types:**
- Disk storage
- Cloud storage (S3, etc.)

**1 Offsite Copy:**
- Different physical location
- Protection against disasters

### Automated Backups

```bash
# Daily backups via cron
0 2 * * * /path/to/backup-site.sh site1
0 3 * * * /path/to/backup-site.sh site2
```

## Disaster Recovery

### Recovery Time Objective (RTO)
- Target: < 1 hour
- Restore from backup
- Redeploy containers

### Recovery Point Objective (RPO)
- Target: < 24 hours
- Daily backups
- Minimal data loss

### DR Procedure

1. **Server Failure:**
   - Provision new server
   - Clone repository
   - Run setup.sh
   - Restore sites from backups

2. **Site Corruption:**
   - Stop affected site
   - Restore from backup
   - Verify functionality
   - Resume service

3. **Data Loss:**
   - Identify backup timestamp
   - Run restore script
   - Validate data integrity

## Performance Optimization

### Traefik
- HTTP/2 enabled
- Compression middleware
- Connection pooling
- Cache headers

### Containers
- Alpine-based images (smaller)
- Multi-stage builds
- Layer caching
- Resource limits

### Databases
- Query optimization
- Indexing
- Connection pooling
- Regular maintenance

## Cost Optimization

### Resource Efficiency
- Shared reverse proxy
- Container density
- Minimal overhead
- Efficient images

### Pricing Model
- Single server: $5-20/month
- Multiple sites: Shared costs
- SSL certificates: Free
- Scaling as needed

## Future Enhancements

### Planned Features
1. **Auto-scaling:** Based on traffic
2. **CDN Integration:** Static asset optimization
3. **Database Clustering:** High availability
4. **Multi-region:** Geographic distribution
5. **Advanced Monitoring:** Metrics and alerts
6. **CI/CD Integration:** Automated deployments
7. **Backup Encryption:** Enhanced security
8. **API Management:** Programmatic control

### Technology Considerations
- **Kubernetes:** For large-scale deployments
- **Consul:** For service discovery
- **Vault:** For secrets management
- **Terraform:** For infrastructure provisioning

## Design Principles

### 1. Simplicity
- Easy to understand
- Minimal dependencies
- Clear documentation

### 2. Security First
- Isolation by default
- Least privilege
- Defense in depth

### 3. Automation
- Scripted operations
- Reduced human error
- Consistent deployments

### 4. Maintainability
- Clear structure
- Standard tools
- Version control

### 5. Scalability
- Horizontal scaling ready
- Resource efficient
- Performance optimized

## Technology Choices

### Why Docker?
- Portability
- Isolation
- Resource efficiency
- Large ecosystem

### Why Traefik?
- Docker-native
- Automatic SSL
- Modern architecture
- Easy configuration

### Why Let's Encrypt?
- Free certificates
- Automated renewal
- Widely trusted
- Easy integration

### Why Cloudflare?
- DNS-01 challenge support
- DDoS protection
- CDN capabilities
- API access

## Conclusion

This architecture provides a solid foundation for hosting multiple websites with:
- Strong security
- Easy management
- Automatic SSL
- Scalability options
- Low cost

The modular design allows for future enhancements while maintaining simplicity and reliability.
