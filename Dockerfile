# Dockerfile for Vikunja (Cloud Run)
FROM vikunja/vikunja:latest
ENV VIKUNJA_SERVICE_PORT=3456
EXPOSE 3456
