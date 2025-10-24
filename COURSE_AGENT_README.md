# Course Recommendation Agent - AWS Bedrock AgentCore

An intelligent course recommendation agent built with AWS Bedrock AgentCore and Strands framework, powered by Amazon Nova Pro. Analyzes career goals and recommends relevant university courses from UTD.

## Features

- **AI-Powered Recommendations**: Uses Amazon Nova Pro for intelligent course matching
- **Real-Time Course Data**: Fetches live course information from UTD Nebula API
- **Career-Focused**: Recommends courses based on specific job roles and career goals
- **Dual Search**: Search by department code or keyword
- **Production-Ready**: Built on AWS Bedrock AgentCore for enterprise deployment
- **Containerized**: Docker support for easy deployment

## Architecture

```
User Career Goal → BedrockAgentCore → Strands Agent (Nova Pro) → Course Tools → Nebula API → Recommendations
```

## Quick Start

### Local Development

1. **Prerequisites**
   - Python 3.10+
   - AWS credentials with Bedrock access
   - UTD Nebula API key ([Get one here](https://api.utdnebula.com))

2. **Setup**
   ```bash
   # Create virtual environment
   python3 -m venv venv
   source venv/bin/activate

   # Install dependencies
   pip install -r course_requirements.txt

   # Configure credentials
   export AWS_ACCESS_KEY_ID=your_aws_key
   export AWS_SECRET_ACCESS_KEY=your_aws_secret
   export AWS_DEFAULT_REGION=us-east-1
   export NEBULA_API_KEY=your_nebula_key
   ```

3. **Run**
   ```bash
   python course_agent.py
   ```

4. **Test**
   ```bash
   # Health check
   curl http://localhost:8080/ping

   # Course recommendation
   curl -X POST http://localhost:8080/invocations \
     -H "Content-Type: application/json" \
     -d '{"inputText": "What courses should I take to become a machine learning engineer?"}'
   ```

## Example Queries

The agent understands natural language queries about career goals:

### Career-Based Queries
```json
{"inputText": "I want to become a software engineer. What courses should I take?"}
{"inputText": "Recommend courses for a data scientist career"}
{"inputText": "What should I study to work in cybersecurity?"}
{"inputText": "I'm interested in AI and machine learning"}
```

### Department Queries
```json
{"inputText": "Show me all Computer Science courses"}
{"inputText": "What upper division Math courses are available?"}
{"inputText": "List all CS courses for beginners"}
```

### Keyword Searches
```json
{"inputText": "Find courses about algorithms"}
{"inputText": "What courses teach database design?"}
{"inputText": "Show me courses related to cloud computing"}
```

## Docker Deployment

### Build Image

```bash
docker build -f course.Dockerfile -t course-agent .
```

### Run Container

```bash
docker run -d \
  -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e NEBULA_API_KEY=your_nebula_key \
  --name course-agent \
  course-agent
```

### Test Container

```bash
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "What courses for data analysis?"}'
```

## AWS Bedrock AgentCore Deployment

### Quick Deploy

```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1
export AGENT_NAME=course-agent

# Build and push to ECR
docker build -f course.Dockerfile -t $AGENT_NAME .
aws ecr create-repository --repository-name $AGENT_NAME --region $AWS_REGION
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag $AGENT_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AGENT_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AGENT_NAME:latest

echo "Image URI: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AGENT_NAME:latest"
```

### Deploy via AWS Console

1. Go to **AWS Console → Amazon Bedrock → AgentCore**
2. Click **Create runtime**
3. Configure:
   - **Name**: `course-agent`
   - **Image URI**: (from above)
   - **Port**: `8080`
   - **Environment variables**:
     - `NEBULA_API_KEY`: your_key
     - `AWS_DEFAULT_REGION`: us-east-1
   - **vCPU**: 0.5, **Memory**: 1 GB
4. Click **Create runtime**

## Available Tools

### get_courses_by_department

Fetches courses filtered by department code and optional class level.

**Parameters:**
- `course_dept` (required): Department code (e.g., 'CS', 'MATH', 'PHYS')
- `course_level` (optional): Class level ('Lower Division', 'Upper Division')

**Example:**
```python
get_courses_by_department(course_dept="CS", course_level="Upper Division")
```

### search_courses_by_keyword

Searches for courses containing a keyword in title or description.

**Parameters:**
- `keyword` (required): Search term
- `max_results` (optional): Maximum results to return (default: 20)

**Example:**
```python
search_courses_by_keyword(keyword="machine learning", max_results=10)
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Yes | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes | - |
| `AWS_DEFAULT_REGION` | AWS region | No | us-east-1 |
| `NEBULA_API_KEY` | UTD Nebula API key | Yes | - |

## API Reference

### Health Check

**Endpoint**: `GET /ping`

**Response**:
```json
{"status": "ok"}
```

### Course Recommendations

**Endpoint**: `POST /invocations`

**Request**:
```json
{
  "inputText": "What courses should I take to become a software engineer?"
}
```

**Response**:
```json
{
  "response": "To become a software engineer, I recommend the following courses:\n\n**Foundational Courses:**\n1. CS 1336 - Programming Fundamentals (3 credits)\n   - Essential programming concepts...\n\n**Core Courses:**\n2. CS 2336 - Object-Oriented Programming...\n..."
}
```

## Common Department Codes

| Code | Department |
|------|------------|
| CS | Computer Science |
| SE | Software Engineering |
| MATH | Mathematics |
| STAT | Statistics |
| PHYS | Physics |
| EECS | Electrical Engineering & Computer Science |
| BIOL | Biology |
| CHEM | Chemistry |
| BCOM | Business Communication |
| MECH | Mechanical Engineering |

## Monitoring

### View Logs

```bash
# Local Docker
docker logs course-agent -f

# AWS CloudWatch
aws logs tail /aws/bedrock/agentcore/course-agent --follow
```

### Key Metrics

- Request count
- Response time
- Nebula API latency
- Error rate
- Course query patterns

## Troubleshooting

### Issue: "API key not configured"

**Solution**: Set NEBULA_API_KEY environment variable
```bash
export NEBULA_API_KEY=your_key_here
```

### Issue: "Failed to fetch courses: HTTP 403"

**Solution**: Verify your Nebula API key is valid
- Get a new key at https://api.utdnebula.com
- Check key permissions

### Issue: No courses returned

**Solution**:
- Verify department code is correct (use uppercase: 'CS', not 'cs')
- Check that Nebula API is accessible
- Try searching by keyword instead

### Issue: Timeout errors

**Solution**:
- Increase timeout in urllib.urlopen (currently 15s)
- Check network connectivity to api.utdnebula.com
- Verify no firewall blocking outbound HTTPS

## Cost Optimization

- **Amazon Nova Pro**: ~$0.0008 per 1K input tokens
- **Nebula API**: Free tier available
- **AgentCore Runtime**: Based on usage (vCPU-hours)

Estimated cost for 1000 requests/day: ~$3-8/month

## Development

### Project Structure

```
.
├── course_agent.py           # Main application
├── course_requirements.txt   # Python dependencies
├── course.Dockerfile        # Container definition
└── COURSE_AGENT_README.md   # This file
```

### Adding New Tools

1. Define tool with `@tool` decorator:
```python
@tool
def get_course_prerequisites(course_id: str) -> dict:
    """Get prerequisites for a specific course"""
    # Implementation
    pass
```

2. Add to agent's tools list:
```python
agent = Agent(
    model=bedrock_model,
    tools=[get_courses_by_department, search_courses_by_keyword, get_course_prerequisites]
)
```

## Testing

### Unit Tests

```bash
# Test Nebula API connection
python -c "from course_agent import get_courses_by_department; print(get_courses_by_department('CS', ''))"

# Test keyword search
python -c "from course_agent import search_courses_by_keyword; print(search_courses_by_keyword('algorithms'))"
```

### Integration Tests

```bash
# Start agent
python course_agent.py &

# Wait for startup
sleep 3

# Test various queries
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Software engineering courses"}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Data science path"}'

# Stop agent
pkill -f course_agent.py
```

## Security Best Practices

1. **API Key Management**: Use AWS Secrets Manager for NEBULA_API_KEY
2. **IAM Roles**: Use IAM roles instead of access keys in production
3. **Network Security**: Deploy in private VPC with NAT Gateway
4. **Rate Limiting**: Implement API Gateway for request throttling
5. **Input Validation**: Agent validates all tool inputs

## Roadmap

- [ ] Add course prerequisite chain analysis
- [ ] Integrate degree plan requirements
- [ ] Add professor ratings integration
- [ ] Support for multiple universities
- [ ] Course schedule optimization
- [ ] Credit hour planning tools

## Support

- **UTD Nebula API**: https://api.utdnebula.com
- **AWS Bedrock**: https://docs.aws.amazon.com/bedrock/
- **Strands SDK**: https://github.com/strands-agents/sdk-python

## License

MIT License

---

Built with ❤️ using AWS Bedrock AgentCore and UTD Nebula API
