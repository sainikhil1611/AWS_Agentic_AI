# Use an official Debian-based Python image as base
FROM python:3.12-slim

# Set environment variables to avoid prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Install curl and ca-certificates safely
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg2 \
        lsb-release \
        apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy your application code
COPY . /app

# Example: install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Default command
CMD ["python", "main.py"]
