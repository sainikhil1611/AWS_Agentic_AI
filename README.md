# Job Search Agent - AWS Bedrock AgentCore

An intelligent job search agent built with AWS Bedrock AgentCore and Strands framework, powered by Amazon Nova Pro.

## Features

- **AI-Powered Search**: Uses Amazon Nova Pro for natural language understanding
- **Tool Integration**: Automatically calls SerpAPI to fetch real job listings
- **Production-Ready**: Built on AWS Bedrock AgentCore for enterprise deployment
- **Containerized**: Docker support for easy deployment

## Architecture

```
User Request → BedrockAgentCore → Strands Agent (Nova Pro) → search_jobs tool → SerpAPI → Response
```

## Quick Start

### Local Development

1. **Prerequisites**
   - Python 3.10+
   - AWS credentials with Bedrock access
   - SerpAPI key (included as default)

2. **Setup**
   ```bash
   # Create virtual environment
   python3 -m venv venv
   source venv/bin/activate

   # Install dependencies
   pip install -r requirements.txt

   # Configure AWS credentials
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   export AWS_DEFAULT_REGION=us-east-1
   ```

3. **Run**
   ```bash
   python agent.py
   ```

4. **Test**
   ```bash
   # In another terminal
   curl -X POST http://localhost:8080/invocations \
     -H "Content-Type: application/json" \
     -d '{"inputText": "Find data scientist jobs in San Francisco"}'
   ```

## Docker Deployment

### Build Image

```bash
docker build -t job-search-agent .
```

### Run Container

```bash
docker run -d \
  -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e SERPAPI_KEY=your_serpapi_key \
  --name job-agent \
  job-search-agent
```

### Test Container

```bash
# Health check
curl http://localhost:8080/ping

# Job search
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Find software engineer jobs"}'
```

## AWS Bedrock AgentCore Deployment

### Option 1: Using AWS Console

1. **Push to ECR**
   ```bash
   # Authenticate to ECR
   aws ecr get-login-password --region us-east-1 | \
     docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

   # Create ECR repository
   aws ecr create-repository --repository-name job-search-agent --region us-east-1

   # Tag and push
   docker tag job-search-agent:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/job-search-agent:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/job-search-agent:latest
   ```

2. **Create AgentCore Runtime**
   - Go to AWS Console → Amazon Bedrock → AgentCore
   - Click "Create runtime"
   - Configure:
     - **Name**: job-search-agent
     - **Container image**: Your ECR image URI
     - **Port**: 8080
     - **Environment variables**:
       - `SERPAPI_KEY`: your_key
       - `AWS_DEFAULT_REGION`: us-east-1
     - **IAM role**: Create role with Bedrock permissions

3. **Deploy**
   - Click "Create runtime"
   - Wait for deployment (2-5 minutes)
   - Get the runtime endpoint URL

### Option 2: Using AWS CLI

```bash
# Set variables
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
AGENT_NAME=job-search-agent
ECR_REPO=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$AGENT_NAME

# Build and push
docker build -t $AGENT_NAME .
aws ecr create-repository --repository-name $AGENT_NAME --region $REGION 2>/dev/null || true
docker tag $AGENT_NAME:latest $ECR_REPO:latest
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO
docker push $ECR_REPO:latest

# Create IAM role (if not exists)
aws iam create-role \
  --role-name BedrockAgentCoreRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "bedrock.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' 2>/dev/null || true

aws iam attach-role-policy \
  --role-name BedrockAgentCoreRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

# Deploy to AgentCore (using Bedrock API)
aws bedrock create-agent-runtime \
  --agent-name $AGENT_NAME \
  --image-uri $ECR_REPO:latest \
  --role-arn arn:aws:iam::$ACCOUNT_ID:role/BedrockAgentCoreRole \
  --environment Variables={SERPAPI_KEY=your_key} \
  --region $REGION
```

### Option 3: Using AWS CDK/CloudFormation

See `deployment/` directory for Infrastructure as Code templates (coming soon).

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Yes | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes | - |
| `AWS_DEFAULT_REGION` | AWS region | No | us-east-1 |
| `SERPAPI_KEY` | SerpAPI key | No | Included |

## API Reference

### Health Check

**Endpoint**: `GET /ping`

**Response**:
```json
{"status": "ok"}
```

### Job Search

**Endpoint**: `POST /invocations`

**Request**:
```json
{
  "inputText": "Find software engineer jobs in Seattle"
}
```

**Response**:
```json
{
  "response": "Here are software engineer jobs in Seattle:\n\n1. Senior Software Engineer at Amazon...\n2. ..."
}
```

## Monitoring & Logging

### CloudWatch Logs

Agent logs are automatically sent to CloudWatch when deployed on AgentCore:

```bash
aws logs tail /aws/bedrock/agentcore/job-search-agent --follow
```

### Metrics

Key metrics to monitor:
- Request count
- Response time
- Error rate
- SerpAPI usage

## Troubleshooting

### Issue: "AccessDeniedException" from Bedrock

**Solution**: Enable Amazon Nova Pro model access
1. AWS Console → Bedrock → Model access
2. Request access to "Amazon Nova Pro"

### Issue: Container won't start

**Solution**: Check environment variables and IAM permissions

```bash
# View container logs
docker logs job-agent

# Check AWS credentials
aws sts get-caller-identity
```

### Issue: No jobs returned

**Solution**: Verify SerpAPI key is valid

```bash
curl "https://serpapi.com/search.json?engine=google_jobs&q=software+engineer&api_key=YOUR_KEY"
```

## Cost Optimization

- **Amazon Nova Pro**: ~$0.0008 per 1K input tokens
- **SerpAPI**: Free tier: 100 searches/month
- **AgentCore Runtime**: Based on usage (vCPU-hours)

Estimated cost for 1000 requests/day: ~$5-10/month

## Security Best Practices

1. **Never commit secrets**: Use AWS Secrets Manager or Parameter Store
2. **Use IAM roles**: Avoid hardcoded credentials in production
3. **Enable VPC**: Deploy AgentCore runtime in private subnet
4. **API Gateway**: Add authentication/rate limiting
5. **Rotate keys**: Regularly rotate SerpAPI and AWS keys

## Development

### Project Structure

```
.
├── agent.py              # Main application
├── requirements.txt      # Python dependencies
├── Dockerfile           # Container definition
├── .dockerignore        # Docker ignore patterns
├── README.md            # This file
├── AWS_CREDENTIALS.md   # AWS setup guide
├── SETUP.md            # Local setup guide
└── TESTING.md          # Testing guide
```

### Adding New Tools

1. Define tool function with `@tool` decorator
2. Add to agent's `tools` list
3. Update system prompt

Example:
```python
@tool
def get_salary_data(job_title: str, location: str) -> dict:
    """Get salary information for a job"""
    # Implementation
    pass

agent = Agent(
    model=bedrock_model,
    tools=[search_jobs, get_salary_data]
)
```

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT License - See LICENSE file

## Support

For issues or questions:
- AWS Bedrock: https://docs.aws.amazon.com/bedrock/
- Strands SDK: https://github.com/strands-agents/sdk-python
- SerpAPI: https://serpapi.com/docs

---

Built with ❤️ using AWS Bedrock AgentCore
