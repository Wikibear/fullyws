# FullyWS - Full Webserver

FullyWS packages PHP 8.2 / 8.3 / 8.5 Apache images that are beefed up for larger web-hosting projects: GD, Redis, Imagick, OPcache, extra extensions, tuned defaults, and the system tooling needed to compile them. Each version lives under `images/<version>/Dockerfile` so GHCR tags can be rebuilt independently.

## Image contents by version

| Version | Base image | Custom builds & PECL modules | Notes |
| --- | --- | --- | --- |
| 8.2 | `php:8.2-apache` | GD (+JPEG/Freetype), mysqli, PDO, `pdo_mysql`, intl, zip, bcmath, soap, xml, mbstring, exif, **opcache**; PECL `redis` + `imagick`; OPcache tuning + PHP defaults; Apache modules (rewrite, headers, expires, deflate, actions). | OPcache is compiled from source so the tuning parameters take effect on both CLI + Apache builds. |
| 8.3 | `php:8.3-apache` | Same as 8.2 (custom compile list + PECL modules). | Mirrors 8.2 for compatibility and security updates; rebuilds the same tuned defaults. |
| 8.5 | `php:8.5-apache` | GD (+JPEG/Freetype), mysqli, PDO, `pdo_mysql`, intl, zip, bcmath, soap, xml, mbstring, exif; PECL `redis` + `imagick`; OPcache tuning + PHP defaults; Apache modules (rewrite, headers, expires, deflate, actions). | Uses the upstream OPcache build while continuing to apply our tuning overrides and PHP defaults. |

## Table of Contents

- [Extras included in every build](#extras-included-in-every-build)
- [Upstream PHP tags](#upstream-php-tags)
- [Tags pushed to GHCR](#tags-pushed-to-ghcr)
- [Local build example](#local-build-example)
- [GitHub Actions](#github-actions)
- [Docker Compose (example)](#docker-compose-example)
- [Quickstart tips](#quickstart-tips)
- [Dockhand stack example](#dockhand-stack-example)
- [License](#license)

## Extras included in every build

- Debian tooling for building PHP extensions (`git`, `unzip`, `libzip`, `libjpeg62-turbo`, `libpng`, `libfreetype6`, `libonig`, `libxml2`, `libssl`, `libicu`, `libmagickwand`, `libcurl4-openssl`, `pkg-config`).
- Compiled-in PHP extensions: `gd` (with JPEG + Freetype), `mysqli`, `pdo`, `pdo_mysql`, `intl`, `zip`, `bcmath`, `soap`, `xml`, `mbstring`, `exif`, plus `opcache` (built manually in `8.2`/`8.3` while inherited from the upstream `php:8.5-apache` image for `8.5`).
- PECL modules: `redis` and `imagick` with corresponding `docker-php-ext-enable` (plus cleanup of `/tmp/pear`).
- OPcache tuning (`memory_consumption`, `interned_strings_buffer`, `max_accelerated_files`, `revalidate_freq`, `fast_shutdown`, `enable_cli`).
- Custom PHP defaults (`memory_limit=256M`, `upload_max_filesize=64M`, `post_max_size=64M`, `max_execution_time=300`).
- Apache modules enabled: `rewrite`, `headers`, `expires`, `deflate`, `actions` plus running `chown -R www-data:www-data /var/www/html` for better security.

## Upstream PHP tags

These builds follow the Debian-based `php:<version>-apache` variants maintained by the Docker Community. For the complete list of supported tags (CLI, Apache, FPM, Alpine, etc.) and their upstream `Dockerfile` links, see the [official Docker Library PHP README](https://github.com/docker-library/docs/blob/master/php/README.md#supported-tags-and-respective-dockerfile-links).

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

The `docker-build.yml` workflow in `.github/workflows` runs on pushes or pull requests targeting `main`, then logs into GHCR and builds the matrix for `8.2`, `8.3`, and `8.5` (each version pushes both the semver tag and the `${version}-${sha}` variant, while `8.5` also seeds the `:latest` tag). Use the Actions tab to inspect log output step-by-step or to rerun failed jobs; you can also trigger the matrix manually with `gh workflow run docker-build.yml --ref main` if you need to rebuild all images outside of a git push.

## Development & publishing

- Reuse the matrix command locally when you need to test builds: `docker build -f images/<version>/Dockerfile -t ghcr.io/wikibear/fullyws:<version> images/<version>` (see the Local build example above) and add a `:sha` tag if you want to mirror what GH Actions produces.
- Authenticate against GHCR before pushing with `docker login ghcr.io -u $USERNAME -p $PAT` (GitHub personal access tokens scoped to `packages:write` work well) and then `docker push ghcr.io/wikibear/fullyws:<version>` plus any additional tags you need.
- Keep the `images/<version>` folders in sync with the workflow matrix—add or remove versions there and update `.github/workflows/docker-build.yml` so the matrix stays accurate.

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

## Local layout & quickstart

- Compose expects your PHP project inside `./www` and the actual document root under `www/public` (matching `APACHE_DOCUMENT_ROOT` in the example stack). Adjust that environment variable or volume mapping if you keep your assets in a different subfolder.
- Seed the folder and add a basic entry point before the first run:

```bash
mkdir -p www/public && cat <<'EOF' > www/public/index.php
<?php
phpinfo();
EOF
```

- With the source tree in place, run `docker compose up` (or `docker compose up -d`) from this repository so Apache serves the mounted `www/public` path in the container.

## Dockhand stack example

If you manage services with Dockhand, here is an `stack.yml` snippet that mirrors the standard Compose setup but names the service `web` and keeps assets in a named `html` volume. It exposes the container on port 8000 and maintains a healthcheck to ensure Apache is running.

```yaml
services:
  web:
    container_name: webserver
    image: ghcr.io/wikibear/fullyws:8.2
    hostname: webserver
    restart: unless-stopped
    ports:
      - "8000:80"
    volumes:
      - html:/var/www/html
    healthcheck:
      test: ["CMD-SHELL", "pidof apache2 > /dev/null || exit 1"]
      interval: 60s
      timeout: 5s
      retries: 5
      start_period: 30s

volumes:
  html:
```

## License

All base images reuse the same licensing as the upstream `php:*` variants (PHP License v3.01). See https://www.php.net/license/3_01.txt for the full text and the Docker Library [PHP README](https://github.com/docker-library/docs/blob/master/php/README.md#license) for how the project tracks additional dependencies.
