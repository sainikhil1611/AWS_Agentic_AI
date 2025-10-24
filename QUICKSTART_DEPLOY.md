# Quick Deployment Guide

Deploy your job search agent to AWS Bedrock AgentCore in 5 steps.

## Prerequisites
- AWS Account with Bedrock access
- Docker installed
- AWS CLI configured

## 5-Step Deployment

### 1. Build Docker Image
```bash
cd /Users/nirmal/Desktop/Agents
docker build -t job-search-agent .
```

### 2. Push to ECR
```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1
export ECR_REPO=job-search-agent

# Create repository
aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push
docker tag job-search-agent:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
```

### 3. Create IAM Role
```bash
# Create role
aws iam create-role \
  --role-name JobSearchAgentRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": ["bedrock.amazonaws.com", "ecs-tasks.amazonaws.com"]},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach policies
aws iam attach-role-policy \
  --role-name JobSearchAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

aws iam attach-role-policy \
  --role-name JobSearchAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### 4. Enable Bedrock Model Access
```bash
# Go to AWS Console
# Navigate to: Amazon Bedrock → Model access
# Enable: Amazon Nova Pro (amazon.nova-pro-v1:0)
```

### 5. Deploy to AgentCore (AWS Console)
1. Open AWS Console → Amazon Bedrock → AgentCore
2. Click "Create runtime"
3. Configure:
   - **Name**: `job-search-agent`
   - **Image URI**: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/job-search-agent:latest`
   - **Port**: `8080`
   - **IAM Role**: `JobSearchAgentRole`
   - **vCPU**: `0.5`, **Memory**: `1 GB`
4. Click "Create runtime"
5. Wait 2-5 minutes for deployment

## Test Deployment

```bash
# Get endpoint from console
export ENDPOINT=https://xxxxx.agentcore.us-east-1.amazonaws.com

# Test
curl -X POST $ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Find software engineer jobs"}'
```

## Files Overview

- **[agent.py](agent.py)** - Main application code
- **[Dockerfile](Dockerfile)** - Container definition
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[README.md](README.md)** - Complete documentation
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Detailed deployment guide
- **[AWS_CREDENTIALS.md](AWS_CREDENTIALS.md)** - AWS setup instructions

## Next Steps

- Set up monitoring: See [DEPLOYMENT.md](DEPLOYMENT.md#monitoring)
- Configure API Gateway for public access
- Add CI/CD pipeline
- Enable auto-scaling

For detailed instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)
