# ------------------------------
# Stage 1: Build stage
# ------------------------------
FROM python:3.12-slim AS builder

# Avoid interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Install required system packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg2 \
        lsb-release \
        build-essential \
        python3-dev \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Python dependencies first for caching
COPY requirements.txt .

# Install Python dependencies in builder stage
RUN pip install --no-cache-dir -r requirements.txt

# ------------------------------
# Stage 2: Final lightweight image
# ------------------------------
FROM python:3.12-slim

# Copy system certificates
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy installed Python packages from builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY . /app

# Set default command
CMD ["python", "main.py"]
