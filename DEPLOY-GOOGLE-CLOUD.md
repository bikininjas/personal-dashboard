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
