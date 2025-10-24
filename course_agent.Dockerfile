# =========================================================
# Course Recommendation Agent Dockerfile (Fixed for Bedrock)
# Compatible architecture: arm64
# =========================================================

# Use an ARM64-compatible Python image (Python 3.11 recommended for stability)
FROM --platform=linux/arm64 python:3.11-slim

# Set working directory
WORKDIR /app

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements (improves Docker layer caching)
COPY course_requirements.txt ./requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY course_agent.py .

# Expose default port for Bedrock AgentCore
EXPOSE 8080

# Add health check - expects FastAPI/Flask app to have /ping endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ping || exit 1

# Run FastAPI app directly (recommended for Bedrock)
CMD ["uvicorn", "course_agent:app", "--host", "0.0.0.0", "--port", "8080"]
