# PHP Apache Images

Vordefinierte PHP/Apache-Builds mit GD, Redis, Imagick, OPcache und sinnvollen Defaults.

## Verfügbare Tags

- `ghcr.io/wikibear/fullyws:8.2`
- `ghcr.io/wikibear/fullyws:8.3`
- `ghcr.io/wikibear/fullyws:8.5`
- `ghcr.io/wikibear/fullyws:latest` (alias für 8.5)

## Aufbau

Jede Version hat ein eigenes Dockerfile unter `images/<version>/Dockerfile` mit identischem Stack.

## Lokales Build (optional)

```bash
docker build -t ghcr.io/wikibear/fullyws:8.5 images/8.5
```

## GitHub Actions

Das Workflow `docker-build.yml` in `.github/workflows` startet den Matrix-Build für alle drei Versionen und pusht die Tags nach GHCR.
