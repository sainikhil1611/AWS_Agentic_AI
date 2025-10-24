# Course Agent - Quick Deployment Guide

Deploy your course recommendation agent to AWS Bedrock AgentCore in 5 steps.

## Prerequisites

- AWS Account with Bedrock access
- Docker installed
- AWS CLI configured
- UTD Nebula API key ([Get here](https://api.utdnebula.com))

## 5-Step Deployment

### 1. Get Nebula API Key

```bash
# Visit: https://api.utdnebula.com
# Sign up and get your API key
export NEBULA_API_KEY=your_nebula_api_key_here
```

### 2. Build Docker Image

```bash
cd /Users/nirmal/Desktop/Agents
docker build -f course.Dockerfile -t course-agent .
```

### 3. Push to Amazon ECR

```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1
export ECR_REPO=course-agent

# Create ECR repository
aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push
docker tag course-agent:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

echo "✓ Image URI: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest"
```

### 4. Create IAM Role (if not exists)

```bash
# Create role
aws iam create-role \
  --role-name CourseAgentRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": ["bedrock.amazonaws.com", "ecs-tasks.amazonaws.com"]},
      "Action": "sts:AssumeRole"
    }]
  }' 2>/dev/null || echo "Role already exists"

# Attach policies
aws iam attach-role-policy \
  --role-name CourseAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

aws iam attach-role-policy \
  --role-name CourseAgentRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### 5. Deploy to AgentCore (AWS Console)

1. Open **AWS Console → Amazon Bedrock → AgentCore**
2. Click **Create runtime**
3. Configure:
   - **Name**: `course-agent`
   - **Image URI**: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/course-agent:latest`
   - **Port**: `8080`
   - **IAM Role**: `CourseAgentRole`
   - **Environment Variables**:
     - `NEBULA_API_KEY` = `your_key`
     - `AWS_DEFAULT_REGION` = `us-east-1`
   - **vCPU**: `0.5`, **Memory**: `1 GB`
4. Click **Create runtime**
5. Wait 2-5 minutes for deployment

## Test Deployment

### Local Test (Before Deploying)

```bash
# Run locally first
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e NEBULA_API_KEY=$NEBULA_API_KEY \
  course-agent

# Wait for startup
sleep 5

# Test health
curl http://localhost:8080/ping

# Test course recommendations
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "What courses should I take to become a software engineer?"}'

# Stop container
docker stop $(docker ps -q --filter ancestor=course-agent)
```

### Production Test (After Deploying)

```bash
# Get endpoint from AWS Console
export ENDPOINT=https://xxxxx.agentcore.us-east-1.amazonaws.com

# Test various queries
curl -X POST $ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Recommend courses for machine learning"}'

curl -X POST $ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Show me all CS upper division courses"}'

curl -X POST $ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "What should I study for cybersecurity?"}'
```

## Example Queries

Try these career-focused queries:

```bash
# Software Engineering
"What courses should I take to become a software engineer?"

# Data Science
"I want to be a data scientist, what courses do you recommend?"

# AI/ML
"Recommend courses for artificial intelligence and machine learning"

# Cybersecurity
"What courses prepare me for a cybersecurity career?"

# Web Development
"What should I study to become a full-stack web developer?"

# Mobile Development
"Courses for mobile app development"

# Cloud Computing
"What courses teach cloud computing and AWS?"

# Database
"I want to work with databases, what should I take?"
```

## Project Files

```
/Users/nirmal/Desktop/Agents/
├── course_agent.py              # Main application
├── course_requirements.txt      # Dependencies
├── course.Dockerfile           # Container definition
├── COURSE_AGENT_README.md      # Full documentation
└── COURSE_DEPLOY.md           # This file
```

## Monitoring

```bash
# View logs (local)
docker logs course-agent -f

# View logs (AWS)
aws logs tail /aws/bedrock/agentcore/course-agent --follow
```

## Troubleshooting

### Issue: Container won't start
```bash
# Check logs
docker logs $(docker ps -lq)

# Verify environment variables
docker inspect $(docker ps -lq) | grep -A 10 Env
```

### Issue: API key error
```bash
# Verify Nebula API key works
curl -H "x-api-key: $NEBULA_API_KEY" https://api.utdnebula.com/course/all | head -100
```

### Issue: No courses found
- Check department code is uppercase: 'CS' not 'cs'
- Verify Nebula API is accessible
- Try keyword search instead

## Cost Estimation

**Monthly costs for 5,000 requests/day:**
- AgentCore Runtime: $15-30
- Amazon Nova Pro: $5-10
- Nebula API: Free
- **Total**: ~$20-40/month

## Next Steps

1. ✅ Deploy to production
2. Set up CloudWatch monitoring
3. Configure auto-scaling
4. Add API Gateway for public access
5. Implement caching for common queries

## Resources

- **Nebula API Docs**: https://api.utdnebula.com
- **AWS Bedrock**: https://docs.aws.amazon.com/bedrock/
- **Full README**: [COURSE_AGENT_README.md](COURSE_AGENT_README.md)

---

Need help? Check [COURSE_AGENT_README.md](COURSE_AGENT_README.md) for detailed documentation.
