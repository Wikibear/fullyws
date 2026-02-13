# PHP Apache Matrix

Minimal PHP 8.2 / 8.3 / 8.5 Apache base images with GD, Redis, Imagick and tuned PHP defaults. Each version lives under `images/<version>/Dockerfile` so GHCR tags can be rebuilt independently.

## Tags pushed to GHCR

- `ghcr.io/wikibear/fullyws:8.2`
- `ghcr.io/wikibear/fullyws:8.3`
- `ghcr.io/wikibear/fullyws:8.5` (also `latest`)
- `ghcr.io/wikibear/fullyws:<sha>` per build for traceability

## Local build example

```bash
docker build -f images/8.5/Dockerfile -t ghcr.io/wikibear/fullyws:8.5 images/8.5
```

## GitHub Actions

The `docker-build.yml` workflow in `.github/workflows` runs a matrix build and pushes every version to GHCR.

## Docker Compose (example)

Create or edit `docker-compose.yml` alongside this README, then place your PHP project under `./www` (e.g., `./www/public/index.php`). Apache serves `/var/www/html`, so keep web assets inside `www` or subdirectories you map. The Compose stack below maps the folder and exposes port 8080:

```yaml
version: "3.9"

services:
  app:
    image: ghcr.io/wikibear/fullyws:latest
    ports:
      - "8080:80"
    volumes:
      - ./www:/var/www/html
    environment:
      APACHE_DOCUMENT_ROOT: /var/www/html/public
    restart: unless-stopped
```

Place your source files (PHP, configs, assets) under `www`, mirror `public` if you use a framework, and commit the folder to your project if needed. Compose will keep them in sync with the container.
