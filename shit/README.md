Let's create a simple Dockerfile with just PHP and Nginx, without Composer or Laravel setup:

```dockerfile
# PHP + Nginx Docker Setup
FROM php:8.1-fpm

# Install Nginx and additional PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Create a simple PHP info file
RUN echo '<?php phpinfo(); ?>' > /var/www/html/index.php

# Configure Nginx
RUN echo 'server { \
    listen 8088; \
    index index.php index.html; \
    server_name localhost; \
    error_log  /var/log/nginx/error.log; \
    access_log /var/log/nginx/access.log; \
    root /var/www/html; \
    \
    location / { \
        try_files $uri $uri/ /index.php?$query_string; \
    } \
    \
    location ~ \.php$ { \
        try_files $uri =404; \
        fastcgi_split_path_info ^(.+\.php)(/.+)$; \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        fastcgi_param PATH_INFO $fastcgi_path_info; \
    } \
}' > /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Configure PHP
RUN echo "memory_limit=256M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Configure supervisor
RUN mkdir -p /var/log/supervisor /var/log/nginx
RUN echo '[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
\n\
[program:php-fpm]\n\
command=php-fpm\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/supervisor/php-fpm.err.log\n\
stdout_logfile=/var/log/supervisor/php-fpm.out.log\n\
\n\
[program:nginx]\n\
command=/usr/sbin/nginx -g "daemon off;"\n\
autostart=true\n\
autorestart=true\n\
stderr_logfile=/var/log/supervisor/nginx.err.log\n\
stdout_logfile=/var/log/supervisor/nginx.out.log\n\
' > /etc/supervisor/conf.d/supervisord.conf

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port
EXPOSE 8088

# Start services with supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

```

This Dockerfile is stripped down to just the essentials:

1. PHP 8.1 with FPM
2. Nginx web server
3. Some common PHP extensions (pdo_mysql, mbstring, etc.)
4. Supervisor to manage both processes
5. A simple index.php file that shows PHP info

To build and run:

```bash
# Build the Docker image
docker build -t simple-php-nginx .

# Run the container
docker run -p 8088:8088 simple-php-nginx
```

After running, you should be able to access the PHP info page at http://localhost:8088 or the appropriate URL in your cloud environment.

To develop with this setup:

1. You can mount your PHP code directory into the container:
   ```bash
   docker run -p 8088:8088 -v ./shit2:/var/www/html simple-php-nginx
   ```

2. Or you can copy your PHP files into the container during the build by modifying the Dockerfile:
   ```dockerfile
   # Add this to the Dockerfile to copy your PHP code
   COPY ./shit2/ /var/www/html/
   ```

This setup should give you a clean, simple environment for PHP development with Nginx.