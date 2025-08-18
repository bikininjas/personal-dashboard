# Personal Dashboard – Vikunja Deployment

This project provides a portable, secure, and easy-to-maintain Docker setup for deploying the Vikunja task management application. It supports both remote SQLite Cloud and PostgreSQL as database backends, with best practices for HTTPS, backups, and secrets management.

---

## Features

- **Vikunja API** deployed via official Docker image

  - Remote SQLite Cloud (experimental, not recommended for production)
  - PostgreSQL (recommended)
- **Reverse Proxy:** Traefik (recommended) or Nginx for HTTPS
- **Automated backup scripts** for both database types
- **Generic Docker host compatibility**

---

1. **Choose your database backend**
2. **Launch with Docker Compose**

    ```bash
    # For SQLite Cloud
    bun run docker-compose -f docker-compose.sqlite.yml up -d

    # For PostgreSQL
    bun run docker-compose -f docker-compose.postgres.yml up -d
    ```

---

## Environment Variables

Create a `.env` file in the project root. Example for SQLite Cloud:

```env
VIKUNJA_DATABASE_TYPE=sqlite
VIKUNJA_DATABASE_PATH=sqlitecloud://user:password@host:port/dbname
```

Example for PostgreSQL:

```env
VIKUNJA_DATABASE_TYPE=postgres
VIKUNJA_DATABASE_HOST=postgres
VIKUNJA_DATABASE_USER=vikunja
VIKUNJA_DATABASE_PASSWORD=yourpassword
VIKUNJA_DATABASE_DATABASE=vikunja

---

## Docker Compose Examples


---


- Traefik is pre-configured for Let's Encrypt certificates.

- **SQLite Cloud:** Use provider API/CLI for regular exports. Automate with scripts in `__backup__` (add to `.gitignore`).
- **PostgreSQL:** Use `pg_dump` in a cron job. Store backups securely and automate retention.

---

## Security Best Practices

- Never commit `.env` or secrets to git
- Use strong, unique passwords
- Keep Docker images up to date
- Restrict network access to services
- Consider Docker secrets for production

---

## References

- [Vikunja Documentation](https://vikunja.io/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [SQLite Cloud](https://sqlitecloud.io/)

---

## License

MIT
