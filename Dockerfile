# Dockerfile for Vikunja (Cloud Run)
FROM vikunja/vikunja:latest
# Les variables d'environnement seront passées par Cloud Run
EXPOSE 3456
