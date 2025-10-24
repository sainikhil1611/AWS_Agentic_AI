# Course Recommendation Agent Dockerfile
# Uses Python 3.13 slim image for smaller size and ARM64 support

FROM --platform=linux/arm64 python:3.13-slim

# Set working directory
WORKDIR /app

# Environment setup
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY course_requirements.txt requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY course_agent.py .

# Expose AgentCore port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/ping')" || exit 1

# Default command
CMD ["python", "course_agent.py"]
