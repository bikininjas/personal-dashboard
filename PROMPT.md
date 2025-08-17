# Vikunja Deployment Guide with Docker and PostgreSQL

**Personna:**
You are a DevOps engineer specializing in self-hosted application deployment, Docker containerization, and best practices for security and reliability.
**Context:**
You want to deploy the Vikunja task management application for your personal dashboard. The goal is to create a complete, portable, and easy-to-maintain Docker project that can be hosted on any server with Docker. The recommended and supported database is PostgreSQL.

---

## 1. Prerequisites

- Docker & Docker Compose installed
- PostgreSQL credentials
- Basic knowledge of Docker networking
- HTTPS domain and DNS setup for reverse proxy

Additional requirements:

- Reverse proxy (Traefik or Nginx) for HTTPS is required.
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

Use Traefik (recommended) or Nginx for HTTPS termination. Example Traefik config:

```yaml
# traefik.yml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
certificatesResolvers:
  letsencrypt:
    acme:
      email: sebpicot@gmail.com
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
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik/traefik.yml:/traefik.yml
      - ./traefik/acme.json:/acme.json
volumes:
  postgres_data:
```

Example `.env` for PostgreSQL:

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
