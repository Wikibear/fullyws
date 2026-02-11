# 🚀 PHP 8.2 Apache – Production Ready Docker Image

Ein optimiertes **PHP 8.2 + Apache** Docker Image mit häufig benötigten Extensions, OPcache Tuning, Redis & Imagick Support – ideal für moderne Webanwendungen wie Laravel, Symfony, WordPress oder eigene PHP-Projekte.

Image:
```
ghcr.io/wikibear/fullyws
```

---

## ✨ Features

✅ PHP 8.2 mit Apache  
✅ GD (JPEG + Freetype Support)  
✅ MySQL / PDO Support  
✅ Redis (PECL)  
✅ Imagick (PECL)  
✅ Intl / ICU Support  
✅ OPcache optimiert  
✅ Apache Modules aktiviert  
✅ Performance- & Production-ready Defaults  

---

## 📦 Installierte PHP Extensions

### Core Extensions
- mysqli
- pdo
- pdo_mysql
- intl
- zip
- bcmath
- soap
- xml
- mbstring
- exif
- opcache

### GD (mit Support für)
- JPEG
- PNG
- Freetype

### PECL Extensions
- redis
- imagick

---

## ⚙️ PHP Konfiguration

### OPcache Settings

```ini
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1
```

### PHP Limits

```ini
memory_limit=256M
upload_max_filesize=64M
post_max_size=64M
max_execution_time=300
```

---

## 🌐 Aktivierte Apache Module

- rewrite
- headers
- expires
- deflate
- actions

Perfekt für Frameworks & SEO-freundliche URLs.

---

# 🐳 Verwendung mit Docker Compose

Beispiel `docker-compose.yml`:

```yaml
version: "3.9"

services:
  app:
    image: ghcr.io/wikibear/fullyws:latest
    container_name: fullyws_app
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./app:/var/www/html
    environment:
      APACHE_DOCUMENT_ROOT: /var/www/html/public
    depends_on:
      - db
      - redis

  db:
    image: mysql:8.0
    container_name: fullyws_db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: app
      MYSQL_USER: app
      MYSQL_PASSWORD: secret
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"

  redis:
    image: redis:7-alpine
    container_name: fullyws_redis
    restart: unless-stopped
    ports:
      - "6379:6379"

volumes:
  db_data:
```

---

## ▶️ Starten

```bash
docker compose up -d
```

App erreichbar unter:

```
http://localhost:8080
```

---

# 📁 Projektstruktur Beispiel

```
project/
│
├── docker-compose.yml
└── app/
    ├── public/
    │   └── index.php
    └── ...
```

---

# 🔐 Security

- Läuft mit www-data
- Kein unnötiger Package Cache
- Minimierte Image-Größe
- PECL Cache entfernt

---

# 🧠 Für welche Projekte geeignet?

- Laravel
- Symfony
- WordPress
- Shopware
- Headless APIs
- Custom PHP Apps
- Microservices

---

# 🛠 Eigene Anpassungen

Falls du das Image erweitern möchtest:

```dockerfile
FROM ghcr.io/wikibear/fullyws:latest

# Beispiel: Composer installieren
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
```

---

# 📄 Lizenz

Eigene Nutzung & Anpassung erlaubt.  
Bitte bei öffentlicher Weiterverwendung Image-Quelle erwähnen.
