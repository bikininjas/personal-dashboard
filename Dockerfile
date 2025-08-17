# Dockerfile for Vikunja (Cloud Run)
FROM vikunja/vikunja:latest
# Configure Vikunja to listen on the port provided by Cloud Run
ENV VIKUNJA_SERVICE_PORT=${PORT}
EXPOSE 8080
