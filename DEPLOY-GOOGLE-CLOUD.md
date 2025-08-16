# Deploying Vikunja to Google Cloud Run – Complete Guide

## 1. Prerequisites

- Google Cloud account and billing enabled
- GitHub repository for your project
- Docker installed locally
- Google Cloud SDK (`gcloud`) installed

## 2. Project Preparation

### a. Clean Up Project Files

- Ensure `.env`, `__backup__/`, and `traefik/acme.json` are listed in `.gitignore` (already set)
- Remove any secrets or sensitive files from the repo
- Do not commit any credentials, passwords, or service account keys

### b. Create a New Branch for Google Cloud Setup

```bash
git checkout -b setup-google-cloud
```

## 3. Google Cloud Setup

### a. Create a Service Account

1. Go to Google Cloud Console > IAM & Admin > Service Accounts
2. Create a new service account (e.g., `github-actions-deployer`)
3. Grant these roles:
   - Cloud Run Admin
   - Artifact Registry Writer
   - (Optional) Cloud SQL Client (if using Cloud SQL Auth Proxy)
4. Create and download a JSON key for this account

### b. Create a Cloud SQL PostgreSQL Instance

1. Go to SQL > Create Instance > PostgreSQL
2. Choose smallest instance (db-f1-micro)
3. Set database name, user, password
4. Enable public IP and set authorized networks

### c. Enable APIs

```bash
gcloud services enable run.googleapis.com sqladmin.googleapis.com artifactregistry.googleapis.com
```

## 4. GitHub Secrets Setup

Add these secrets in your GitHub repository (Settings > Secrets and variables > Actions):

| Name            | Value (example)                |
|-----------------|-------------------------------|
| GCP_SA_KEY      | (Paste JSON file contents)     |
| GCP_PROJECT_ID  | my-gcp-project-123            |
| PG_HOST         | 34.123.45.67                  |
| PG_USER         | vikunja                       |
| PG_PASSWORD     | yourpassword                  |
| PG_DATABASE     | vikunja                       |

## 5. GitHub Actions Workflow

The workflow file is at `.github/workflows/deploy-cloudrun.yml`. It will:

- Build and push your Docker image to Google Artifact Registry
- Deploy the container to Cloud Run
- Pass secrets as environment variables

## 6. Deployment

Push your changes to the new branch:

```bash
git add .
git commit -m "Google Cloud Run setup: clean files, add workflow, update docs"
git push origin setup-google-cloud
```

Open a pull request to merge into `master` when ready.

## 7. Security Best Practices

- Never commit secrets, `.env`, or service account keys to git
- Use `.gitignore` to exclude sensitive files
- Use GitHub Actions secrets for all credentials

## 8. References

- [Vikunja Documentation](https://vikunja.io/docs/)
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Google Cloud SQL](https://cloud.google.com/sql/docs)
- [GitHub Actions for Google Cloud](https://github.com/google-github-actions)

## Creating the PostgreSQL Database on Google Cloud SQL

1. Go to the [Google Cloud Console SQL section](https://console.cloud.google.com/sql/instances).
2. Click **Create Instance** and select **PostgreSQL**.
3. Choose the smallest machine type (e.g., db-f1-micro) for lowest cost.
4. Set the instance ID (e.g., `vikunja-db`), root password, and region.
5. After creation, click the instance and go to the **Databases** tab.
6. Click **Create database** and enter the name (e.g., `vikunja`).
7. Go to the **Users** tab and create a user (e.g., `vikunja`) with a secure password.
8. Go to the **Connections** tab and enable **Public IP**.
9. Add your Cloud Run service’s IP or 0.0.0.0/0 (for testing) to the authorized networks.
10. Note the public IP address of your instance.

**Use these values for your GitHub Actions secrets:**
- `PG_HOST`: The public IP address of your Cloud SQL instance
- `PG_USER`: The database user you created (e.g., `vikunja`)
- `PG_PASSWORD`: The password you set
- `PG_DATABASE`: The database name you created (e.g., `vikunja`)

**Security tip:** For production, restrict authorized networks to only your Cloud Run service or use the Cloud SQL Auth Proxy for secure connections.

---
