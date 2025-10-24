# Course Agent Dockerfile (ARM64, cross-build safe)
FROM --platform=linux/arm64 python:3.13-slim

# Set working directory
WORKDIR /app

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies (safe for QEMU/ARM64 builds)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
        lsb-release \
        apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY course_requirements.txt requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY course_agent.py .

# Expose AgentCore default port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/ping')" || exit 1

# Run the agent
CMD ["python", "course_agent.py"]
