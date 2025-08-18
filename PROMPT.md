# Vikunja Deployment Guide with Docker and PostgreSQL

You are a DevOps engineer specializing in self-hosted application deployment, Docker containerization, and best practices for security and reliability.
**Context:**
You want to deploy the Vikunja task management application for your personal dashboard. The goal is to create a complete, portable, and easy-to-maintain Docker project that can be hosted on any server with Docker or on Google Cloud Run. The only recommended and supported database is PostgreSQL.

## 1. Prerequisites

- Docker & Docker Compose installed
Additional requirements:

- Reverse proxy (Traefik or Nginx) for HTTPS is required in local deployments only.
- Automated backup scripts must be included.
- Deployment instructions should be generic for any Docker host.
- Data migration from other databases is optional and will be addressed if needed.

---

## Table of Contents

- [Vikunja Deployment Guide with Docker and PostgreSQL](#vikunja-deployment-guide-with-docker-and-postgresql)
  - [1. Prerequisites](#1-prerequisites)
  - [Table of Contents](#table-of-contents)
  - [1. Technical Analysis and Recommended Architecture](#1-technical-analysis-and-recommended-architecture)
    - [Recommended Architecture](#recommended-architecture)
  - [Backup \& Restore](#backup--restore)
    - [Exemple](#exemple)
  - [Reverse Proxy Setup (HTTPS)](#reverse-proxy-setup-https)
  - [Docker Compose Example](#docker-compose-example)
  - [CI/CD for Google Cloud Run](#cicd-for-google-cloud-run)
    - [GitHub Actions Workflow Example](#github-actions-workflow-example)
    - [Best Practices for CI/CD](#best-practices-for-cicd)

---

## 1. Technical Analysis and Recommended Architecture

### Recommended Architecture

**Use a client-server database like PostgreSQL**. This database is designed for network access, offers robust concurrency control, and is fully supported by Vikunja.

---

## Backup & Restore

- **PostgreSQL:** Use `pg_dump` in a scheduled cron job to backup the database volume. Store backups securely and automate retention/rotation.
- Always test restore procedures before relying on backups.

### Exemple

<https://vikunja.io/docs/full-docker-example/>

---

## Reverse Proxy Setup (HTTPS)

```yaml
web:
  address: ":80"
websecure:
  address: ":443"
certificatesResolvers:
  letsencrypt:
    acme:
      email: <sebpicot@gmail.com>
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

---

## Docker Compose Example

```yaml
# Example docker-compose for PostgreSQL
version: '3.7'
services:
  vikunja:
    image: vikunja/vikunja
    env_file:
      - .env
    ports:
      - "3456:3456"
    restart: unless-stopped
    depends_on:
      - postgres
      - proxy
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: vikunja
      POSTGRES_USER: vikunja
      POSTGRES_PASSWORD: yourpassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
  proxy:
    image: traefik:v2.10
    command:
      - --api.insecure=true
      - --providers.docker=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
    ports:
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik/traefik.yml:/traefik.yml
      - ./traefik/acme.json:/acme.json
volumes:
  postgres_data:
```

```env
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_HOST=postgres
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=yourpassword
VIKUNJA_DATABASE_DATABASE=vikunja
```

**Best Practices:**

- Never commit `.env` files to git.
- Use strong, unique passwords.
- Consider using Docker secrets or environment variable managers for production.

---

## CI/CD for Google Cloud Run

### GitHub Actions Workflow Example

Automate build, push, and deploy to Cloud Run with secrets:

```yaml
name: Deploy Vikunja to Google Cloud Run

on:
  push:
    branches:
      - master

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    env:
      PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  REGION: europe-west9
      SERVICE: vikunja
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCS_GH_SVC_ACCOUNT_JSON_KEY }}

      - name: Configure Docker for Google Artifact Registry
        run: |
          gcloud auth configure-docker europe-west9-docker.pkg.dev

      - name: Build and push Docker image
        run: |
          docker build -t europe-west9-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/vikunja/vikunja:latest .
          docker push europe-west9-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/vikunja/vikunja:latest

      - name: Deploy to Cloud Run
        uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: ${{ env.SERVICE }}
          image: europe-west9-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/vikunja/vikunja:latest
          region: ${{ env.REGION }}
          env_vars: |
            VIKUNJA_SERVICE_PORT=8080
            VIKUNJA_DATABASE_TYPE=postgres
            VIKUNJA_DATABASE_HOST=${{ secrets.PG_VIKUNJA_IP }}
            VIKUNJA_DATABASE_USER=${{ secrets.PG_VIKUNJA_USER }}
            VIKUNJA_DATABASE_DATABASE=${{ secrets.PG_VIKUNJA_DATABASE }}
            VIKUNJA_DATABASE_PASSWORD=VIKUNJA_DATABASE_PASSWORD
          secrets: |
            VIKUNJA_DATABASE_PASSWORD=vikunja-db-password:latest
```

### Best Practices for CI/CD

- Never commit secrets or `.env` files to git
- Use GitHub Secrets and Google Secret Manager for sensitive data
- Mask secrets in logs (`::add-mask::`)
- Clean up workflow runs to remove sensitive logs
- Automate rollback and error notifications
- Monitor deployment status and logs after each run
