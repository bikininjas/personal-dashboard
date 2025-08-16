# Vikunja Deployment Guide with Docker and Remote SQLite Cloud
 
**Personna:**
You are a DevOps engineer specializing in self-hosted application deployment, Docker containerization, and best practices for security and reliability.
**Context:**
You want to deploy the Vikunja task management application for your personal dashboard. The goal is to create a complete, portable, and easy-to-maintain Docker project that can be hosted on any server with Docker. A major constraint is that your data must be stored in a remote SQLite database hosted on SQLite Cloud, using the following connection string (can be found in `.env` file):

If sqlite is a bad choice we'll switch to postgres

---

## 1. Prerequisites

- Docker & Docker Compose installed
- Access to SQLite Cloud (connection string)
- (Optional) PostgreSQL credentials
- Basic knowledge of Docker networking
- HTTPS domain and DNS setup for reverse proxy

Additional requirements:

Additional requirements:

- Reverse proxy (Traefik or Nginx) for HTTPS is required.
- Automated backup scripts must be included.
- Deployment instructions should be generic for any Docker host.
- Data migration between SQLite Cloud and PostgreSQL is optional and will be addressed if needed.


---

## Table of Contents

- [Vikunja Deployment Guide with Docker and Remote SQLite Cloud](#vikunja-deployment-guide-with-docker-and-remote-sqlite-cloud)
  - [1. Prerequisites](#1-prerequisites)
  - [Table of Contents](#table-of-contents)
  - [1. Technical Analysis and Recommended Architecture](#1-technical-analysis-and-recommended-architecture)
    - [Why Remote SQLite is a Bad Practice](#why-remote-sqlite-is-a-bad-practice)
    - [Recommended Architecture](#recommended-architecture)
  - [Backup \& Restore](#backup--restore)
    - [Exemple](#exemple)
  - [Reverse Proxy Setup (HTTPS)](#reverse-proxy-setup-https)
  - [Docker Compose Examples](#docker-compose-examples)
    - [With SQLite Cloud](#with-sqlite-cloud)
    - [With PostgreSQL](#with-postgresql)
  - [Environment Variables \& Secrets Management](#environment-variables--secrets-management)

---

## 1. Technical Analysis and Recommended Architecture

### Why Remote SQLite is a Bad Practice

- **Latency:** SQLite is designed for local, embedded use. Remote access introduces network latency, which can severely degrade performance.
- **Concurrency:** SQLite does not handle concurrent writes well, especially over a network. This can lead to database corruption or lost data.
- **No Native Support:** Most web applications, including Vikunja, expect a client-server database (like PostgreSQL or MySQL) and do not support remote SQLite connections out of the box.
- **Protocol Limitations:** The `sqlitecloud://` protocol is not standard and is not supported by Vikunja or most ORMs.

### Recommended Architecture

**Use a client-server database like PostgreSQL or MariaDB** instead. These databases are designed for network access, offer robust concurrency control, and are fully supported by Vikunja.


---

## Backup & Restore

- **SQLite Cloud:** Use the provider's API or CLI to export backups regularly. Automate with a script and store backups in a secure location. Example script:
  - Place scripts in a `__backup__` directory and add to `.gitignore`.
- **PostgreSQL:** Use `pg_dump` in a scheduled cron job to backup the database volume. Store backups securely and automate retention/rotation.
- Always test restore procedures before relying on backups.

### Exemple

<https://vikunja.io/docs/full-docker-example/>

---

## Reverse Proxy Setup (HTTPS)

Use Traefik (recommended) or Nginx for HTTPS termination. Example Traefik config:
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

## Docker Compose Examples
### With SQLite Cloud

```yaml
# Example docker-compose for SQLite Cloud
version: '3.7'
services:
  vikunja:
    image: vikunja/api
    env_file:
      - .env
    ports:
      - "3456:3456"
    restart: unless-stopped
    depends_on:
      - proxy
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
```

### With PostgreSQL

```yaml
# Example docker-compose for PostgreSQL
version: '3.7'
services:
  vikunja:
    image: vikunja/api
    env_file:
      - .env
    ports:
      - "3456:3456"
    restart: unless-stopped
    depends_on:
      - db
      - proxy
  db:
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

Example `.env` for SQLite Cloud:

```env
VIKUNJA_DATABASE_TYPE=sqlite
VIKUNJA_DATABASE_PATH=sqlitecloud://user:password@host:port/dbname
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
 

### With SQLite Cloud

```yaml
version: '3.7'
services:
  vikunja:
    image: vikunja/api
    env_file:
      - .env
    ports:
      - "3456:3456"
    restart: unless-stopped
    depends_on:
      - proxy
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
```

### With PostgreSQL

```yaml
version: '3.7'
services:

  ---

  ## Environment Variables & Secrets Management

  Example `.env` for SQLite Cloud:

  ```env
  VIKUNJA_DATABASE_TYPE=sqlite
  VIKUNJA_DATABASE_PATH=sqlitecloud://user:password@host:port/dbname
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

---

## Environment Variables & Secrets Management

Example `.env` for SQLite Cloud:
```
VIKUNJA_DATABASE_TYPE=sqlite
VIKUNJA_DATABASE_PATH=sqlitecloud://user:password@host:port/dbname
```

Example `.env` for PostgreSQL:
```
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

