# AWS Bedrock AgentCore Deployment Guide

Complete guide to deploy your job search agent to AWS Bedrock AgentCore.

## Prerequisites

- AWS Account with Bedrock access
- Docker installed locally
- AWS CLI configured
- Amazon Nova Pro model access enabled

## Step-by-Step Deployment

### Step 1: Enable Bedrock Model Access

```bash
# Go to AWS Console
# Navigate to: Amazon Bedrock → Model access
# Enable: Amazon Nova Pro (amazon.nova-pro-v1:0)
```

Or via CLI:
```bash
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{"modelInvocationLoggingConfiguration":{"enabled":true}}' \
  --region us-east-1
```

### Step 2: Build Docker Image

```bash
cd /Users/nirmal/Desktop/Agents

# Build the image
docker build -t job-search-agent:latest .

# Test locally first
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  job-search-agent:latest

# Test it works
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Find jobs"}'

# Stop test container
docker stop $(docker ps -q --filter ancestor=job-search-agent:latest)
```

### Step 3: Push to Amazon ECR

```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1
export ECR_REPO_NAME=job-search-agent
export ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME

# Create ECR repository
aws ecr create-repository \
  --repository-name $ECR_REPO_NAME \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_URI

# Tag image
docker tag job-search-agent:latest $ECR_URI:latest

# Push to ECR
docker push $ECR_URI:latest

echo "✓ Image pushed to: $ECR_URI:latest"
```

### Step 4: Create IAM Role for AgentCore

```bash
# Create trust policy
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "bedrock.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name JobSearchAgentRole \
  --assume-role-policy-document file://trust-policy.json

# Attach Bedrock permissions
aws iam attach-role-policy \
  --role-name JobSearchAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

# Attach ECR permissions
aws iam attach-role-policy \
  --role-name JobSearchAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

# Get role ARN
export ROLE_ARN=$(aws iam get-role --role-name JobSearchAgentRole --query 'Role.Arn' --output text)
echo "✓ Role created: $ROLE_ARN"

# Clean up temp file
rm trust-policy.json
```

### Step 5: Deploy to Bedrock AgentCore

#### Option A: Using AWS Console (Easiest)

1. **Navigate to AgentCore**
   - Open AWS Console
   - Go to Amazon Bedrock
   - Click "AgentCore" in left sidebar
   - Click "Create runtime"

2. **Configure Runtime**
   - **Runtime name**: `job-search-agent`
   - **Container image URI**: Paste ECR URI from Step 3
   - **Port**: `8080`
   - **IAM role**: Select `JobSearchAgentRole`

3. **Environment Variables**
   - Click "Add environment variable"
   - Add: `SERPAPI_KEY` = `your_key` (optional, has default)
   - Add: `AWS_DEFAULT_REGION` = `us-east-1`

4. **Compute Configuration**
   - **vCPU**: 0.5
   - **Memory**: 1 GB
   - **Auto-scaling**: Min 1, Max 10

5. **Deploy**
   - Click "Create runtime"
   - Wait 2-5 minutes for deployment
   - Status should change to "Active"

6. **Get Endpoint**
   - Copy the runtime endpoint URL
   - Format: `https://xxxxx.agentcore.us-east-1.amazonaws.com`

#### Option B: Using Bedrock Agent API

Currently, AgentCore is managed through the console. AWS CLI support coming soon.

### Step 6: Test Deployed Agent

```bash
# Set your AgentCore endpoint
export AGENTCORE_ENDPOINT=https://xxxxx.agentcore.us-east-1.amazonaws.com

# Test health check
curl $AGENTCORE_ENDPOINT/ping

# Test job search
curl -X POST $AGENTCORE_ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(aws sts get-session-token --query 'Credentials.SessionToken' --output text)" \
  -d '{"inputText": "Find software engineer jobs in Seattle"}'
```

### Step 7: Set Up API Gateway (Optional)

For public access with authentication:

```bash
# Create REST API
aws apigateway create-rest-api \
  --name job-search-agent-api \
  --region us-east-1

# Create VPC Link (if AgentCore is in VPC)
# Configure routes, authentication, and throttling
# See AWS API Gateway documentation for details
```

## Production Checklist

- [ ] Enable CloudWatch logging
- [ ] Set up CloudWatch alarms
- [ ] Configure auto-scaling policies
- [ ] Enable AWS X-Ray tracing
- [ ] Set up API Gateway with API keys
- [ ] Implement rate limiting
- [ ] Use AWS Secrets Manager for SERPAPI_KEY
- [ ] Enable VPC for network isolation
- [ ] Set up CI/CD pipeline
- [ ] Configure backup and disaster recovery

## Monitoring

### View Logs

```bash
# Find log group
aws logs describe-log-groups --log-group-name-prefix /aws/bedrock/agentcore

# Tail logs
aws logs tail /aws/bedrock/agentcore/job-search-agent --follow
```

### CloudWatch Metrics

Monitor these metrics in CloudWatch:
- `Invocations` - Total requests
- `Duration` - Response time
- `Errors` - Error count
- `Throttles` - Rate limit hits

### Set Up Alarms

```bash
# Create alarm for errors
aws cloudwatch put-metric-alarm \
  --alarm-name job-agent-errors \
  --alarm-description "Alert on agent errors" \
  --metric-name Errors \
  --namespace AWS/Bedrock/AgentCore \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

## Updates & Rollbacks

### Deploy New Version

```bash
# Build new version
docker build -t job-search-agent:v2 .

# Tag and push
docker tag job-search-agent:v2 $ECR_URI:v2
docker push $ECR_URI:v2

# Update AgentCore runtime in console
# Or update ECS task definition with new image
```

### Rollback

```bash
# Push previous version
docker tag job-search-agent:v1 $ECR_URI:latest
docker push $ECR_URI:latest

# Update runtime to use previous image
```

## Scaling

AgentCore auto-scales based on:
- CPU utilization
- Request count
- Custom metrics

Configure in Console:
- Min instances: 1
- Max instances: 10
- Target CPU: 70%

## Security

### Use Secrets Manager

```bash
# Store SerpAPI key
aws secretsmanager create-secret \
  --name job-agent/serpapi-key \
  --secret-string "your_serpapi_key"

# Update agent.py to fetch from Secrets Manager
# See AWS_CREDENTIALS.md for code example
```

### Enable VPC

1. Create VPC with private subnets
2. Configure AgentCore runtime to use VPC
3. Add NAT Gateway for outbound SerpAPI calls
4. Update security groups

## Cost Estimation

**Monthly costs for 10,000 requests/day:**

- AgentCore Runtime: $20-40 (0.5 vCPU, 1GB RAM)
- Amazon Nova Pro: $10-15 (API calls)
- SerpAPI: $0-50 (depends on tier)
- Data transfer: $5-10
- **Total**: ~$35-115/month

## Troubleshooting

### Runtime fails to start

```bash
# Check CloudWatch logs
aws logs tail /aws/bedrock/agentcore/job-search-agent --follow

# Common issues:
# - Missing IAM permissions
# - Invalid environment variables
# - Container health check failing
```

### High latency

- Enable CloudWatch Insights
- Check SerpAPI response times
- Increase compute resources
- Enable response caching

### Authentication errors

- Verify IAM role has Bedrock permissions
- Check model access is enabled
- Validate AWS credentials in container

## Next Steps

1. ✅ Deploy to production
2. Set up monitoring and alerts
3. Implement CI/CD pipeline
4. Add more tools and features
5. Enable caching for common queries
6. Add conversation memory
7. Integrate with frontend application

## Resources

- [AWS Bedrock AgentCore Docs](https://docs.aws.amazon.com/bedrock/latest/userguide/agentcore.html)
- [Strands SDK](https://github.com/strands-agents/sdk-python)
- [Amazon ECR Guide](https://docs.aws.amazon.com/ecr/)
- [CloudWatch Monitoring](https://docs.aws.amazon.com/cloudwatch/)

---

Need help? Check AWS_CREDENTIALS.md and TESTING.md
