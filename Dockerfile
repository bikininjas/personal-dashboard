# Dockerfile for Vikunja (Cloud Run)
FROM vikunja/vikunja:latest
ENV VIKUNJA_SERVICE_PORT=8080
EXPOSE 8080
