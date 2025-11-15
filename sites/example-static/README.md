# Static Site Template

Deploy static HTML websites with Nginx and automatic SSL.

## Features

- Nginx web server (Alpine-based)
- Automatic HTTPS/SSL certificates
- Gzip compression
- Security headers
- Custom error pages support

## Quick Deploy

```bash
# Using deploy script
./scripts/deploy-site.sh static mysite mysite.com

# Or manually
cp -r sites/example-static sites/mysite
cd sites/mysite
cp .env.example .env
nano .env  # Configure your settings
docker-compose up -d
```

## Directory Structure

```
mysite/
├── docker-compose.yml    # Container configuration
├── .env                  # Environment variables
├── nginx.conf            # Nginx configuration
└── html/                 # Your website files
    ├── index.html
    ├── assets/
    │   ├── css/
    │   ├── js/
    │   └── images/
    └── ...
```

## Adding Your Content

1. Place your HTML files in `html/` directory
2. Organize assets in subdirectories
3. Main page should be `index.html`

```bash
cd sites/mysite
cp -r /path/to/your/site/* html/
```

## Customizing Nginx

Edit `nginx.conf` to customize:

### Enable Directory Listing

```nginx
location / {
    autoindex on;
    try_files $uri $uri/ =404;
}
```

### Add Custom Headers

```nginx
location / {
    add_header X-Custom-Header "value";
    try_files $uri $uri/ =404;
}
```

### Enable Caching

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Password Protection

1. Generate password file:
```bash
htpasswd -c .htpasswd username
```

2. Add to nginx.conf:
```nginx
location / {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
    try_files $uri $uri/ =404;
}
```

3. Mount in docker-compose.yml:
```yaml
volumes:
  - ./.htpasswd:/etc/nginx/.htpasswd:ro
```

## Custom Error Pages

Create custom error pages:

```bash
cd html
cat > 404.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Page Not Found</title></head>
<body>
    <h1>404 - Page Not Found</h1>
    <p>The page you're looking for doesn't exist.</p>
</body>
</html>
EOF
```

Update nginx.conf:
```nginx
error_page 404 /404.html;
location = /404.html {
    internal;
}
```

## Single Page Applications (SPA)

For React, Vue, Angular apps:

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

## Performance Optimization

### Enable HTTP/2

Already enabled by Traefik!

### Optimize Gzip

In nginx.conf:
```nginx
gzip on;
gzip_vary on;
gzip_min_length 256;
gzip_types
    text/plain
    text/css
    text/javascript
    application/javascript
    application/json
    image/svg+xml;
```

### Add Browser Caching

```nginx
location ~* \.(html|css|js)$ {
    expires 1h;
    add_header Cache-Control "public";
}

location ~* \.(jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## Common Tasks

### Update Website Content

```bash
cd sites/mysite
# Update files in html/
docker-compose restart  # Restart to apply changes
```

### View Logs

```bash
docker-compose logs -f
```

### Test Configuration

```bash
# Test nginx config syntax
docker-compose exec nginx nginx -t

# Reload nginx
docker-compose exec nginx nginx -s reload
```

## Backup & Restore

### Backup

```bash
./scripts/backup-site.sh mysite
```

### Restore

```bash
./scripts/restore-site.sh mysite 20250115_120000
```

## Troubleshooting

### 403 Forbidden

Check file permissions:
```bash
chmod -R 755 html/
chmod 644 html/**/*.html
```

### Changes Not Visible

1. Clear browser cache
2. Restart container:
```bash
docker-compose restart
```

### Nginx Won't Start

Check configuration:
```bash
docker-compose logs nginx
nginx -t  # in container
```

## Examples

### Basic HTML5 Site

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Site</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <h1>Welcome to My Site</h1>
    <script src="assets/js/main.js"></script>
</body>
</html>
```

### With Bootstrap

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bootstrap Site</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>Hello, World!</h1>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

## Security

- Files served as read-only
- No PHP execution
- Security headers applied by Traefik
- HTTPS enforced

## Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [HTML5 Boilerplate](https://html5boilerplate.com/)
- [MDN Web Docs](https://developer.mozilla.org/)
