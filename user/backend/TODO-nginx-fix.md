# Nginx Config Fix - backend/nginx/conf.d/default.conf

## Steps:
- [ ] 1. Replace content in backend/nginx/conf.d/default.conf with complete Laravel Nginx server block
- [ ] 2. docker-compose down && docker-compose up -d --build (run from backend/)
- [ ] 3. docker-compose logs nginx
- [ ] 4. Test access: curl http://localhost:8080 or browser

**Complete config to use:**
```
server {
    listen 80;
    index index.php index.html index.htm;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;
    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\. {
        deny all;
    }
}
```

