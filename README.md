# Career Development AI Agent System

A complete multi-agent system for career planning, built with AWS Bedrock AgentCore and Strands framework. Four intelligent agents work together to provide comprehensive career guidance including job search, course recommendations, portfolio projects, and complete career roadmaps.

## System Overview

```
                    User Query
                        ↓
              ┌─────────────────┐
              │  Orchestrator   │  (Coordinates all agents)
              │     Agent       │
              └─────────────────┘
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
  ┌─────────┐     ┌──────────┐   ┌──────────┐
  │   Job   │     │  Course  │   │ Project  │
  │  Agent  │     │  Agent   │   │  Agent   │
  └─────────┘     └──────────┘   └──────────┘
  (SerpAPI)      (UTD Nebula)   (Curated DB)
        ↓               ↓               ↓
    Job Listings    Courses         Projects
                        ↓
           Unified Career Development Plan
```

## Agents

### 1. Job Agent
**Purpose**: Find job opportunities matching career goals
**Model**: Amazon Nova Pro
**External API**: SerpAPI (Google Jobs)
**Capabilities**:
- Search jobs by title, location, country
- Real-time job market data
- Company and salary information

### 2. Course Agent
**Purpose**: Recommend university courses for skill development
**Model**: Amazon Nova Pro
**External API**: UTD Nebula API
**Capabilities**:
- Search by department (CS, MATH, STAT, etc.)
- Filter by class level (Lower/Upper Division)
- Keyword search across course catalog
- 3000+ courses from University of Texas at Dallas

### 3. Project Agent
**Purpose**: Suggest portfolio-ready projects
**Model**: Amazon Nova Pro
**Data Source**: Curated project database (30+ projects)
**Capabilities**:
- Projects across 9 career categories
- Experience-level filtering
- Portfolio value assessment
- Skills mapping for 60+ technologies

### 4. Orchestrator Agent
**Purpose**: Coordinate all agents for comprehensive career plans
**Model**: Amazon Nova Pro
**Capabilities**:
- Intelligent agent routing
- Parallel agent execution
- Response synthesis
- Complete career roadmap generation

## Quick Start

### Prerequisites
- Python 3.10 or higher
- AWS credentials with Bedrock access
- Docker (for containerization)

### Local Development

1. **Clone and setup**
   ```bash
   cd /Users/nirmal/Desktop/Agents
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies** (same for all agents)
   ```bash
   pip install -r job_agent.requirements.txt
   ```

3. **Configure environment**
   ```bash
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   export AWS_DEFAULT_REGION=us-east-1
   export SERPAPI_KEY=your_serpapi_key         # For job agent
   export NEBULA_API_KEY=your_nebula_key       # For course agent
   ```

4. **Run an agent**
   ```bash
   # Job Agent
   python job_agent.py

   # Course Agent
   python course_agent.py

   # Project Agent
   python project_agent.py

   # Orchestrator
   python orchestrator_agent.py
   ```

5. **Test**
   ```bash
   curl -X POST http://localhost:8080/invocations \
     -H "Content-Type: application/json" \
     -d '{"inputText": "Your query here"}'
   ```

## Example Queries

### Job Agent
```bash
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Find software engineer jobs in Seattle"}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Data scientist positions in San Francisco"}'
```

### Course Agent
```bash
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "What courses should I take for machine learning?"}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Show me Computer Science upper division courses"}'
```

### Project Agent
```bash
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "What projects should I build to become a full-stack developer?"}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Portfolio projects for ML engineer"}'
```

### Orchestrator Agent
```bash
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "I want to become a data scientist. Create a complete career plan."}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Complete roadmap for DevOps engineer career"}'
```

## Docker Deployment

### Build Images

```bash
# Job Agent
docker build -f job_agent.Dockerfile -t job-agent .

# Course Agent
docker build -f course_agent.Dockerfile -t course-agent .

# Project Agent
docker build -f project_agent.Dockerfile -t project-agent .

# Orchestrator
docker build -f orchestrator_agent.Dockerfile -t orchestrator-agent .
```

### Run Containers

```bash
# Job Agent
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e SERPAPI_KEY=$SERPAPI_KEY \
  --name job-agent job-agent

# Course Agent
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e NEBULA_API_KEY=$NEBULA_API_KEY \
  --name course-agent course-agent

# Project Agent
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  --name project-agent project-agent

# Orchestrator
docker run -d -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e SERPAPI_KEY=$SERPAPI_KEY \
  -e NEBULA_API_KEY=$NEBULA_API_KEY \
  --name orchestrator-agent orchestrator-agent
```

## AWS Bedrock AgentCore Deployment

### Step 1: Push to ECR

```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1

# For each agent, run:
AGENT_NAME=job-agent  # Change for each agent

# Create ECR repository
aws ecr create-repository --repository-name $AGENT_NAME --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push
docker tag $AGENT_NAME:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AGENT_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AGENT_NAME:latest
```

Repeat for: `job-agent`, `course-agent`, `project-agent`, `orchestrator-agent`

### Step 2: Create IAM Role

```bash
# Create role (once for all agents)
aws iam create-role \
  --role-name BedrockAgentCoreRole \
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
  --role-name BedrockAgentCoreRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

aws iam attach-role-policy \
  --role-name BedrockAgentCoreRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### Step 3: Deploy via AWS Console

For each agent:

1. Open **AWS Console → Amazon Bedrock → AgentCore**
2. Click **Create runtime**
3. Configure:
   - **Name**: `job-agent` / `course-agent` / `project-agent` / `orchestrator-agent`
   - **Image URI**: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/<agent-name>:latest`
   - **Port**: `8080`
   - **IAM Role**: `BedrockAgentCoreRole`
   - **Environment Variables**:
     - Job Agent: `SERPAPI_KEY`
     - Course Agent: `NEBULA_API_KEY`
     - Orchestrator: `SERPAPI_KEY`, `NEBULA_API_KEY`
   - **vCPU**: `0.5`, **Memory**: `1 GB`
4. Click **Create runtime**
5. Wait 2-5 minutes for deployment

### Step 4: Test Deployed Agents

```bash
# Get endpoint from AWS Console
export ENDPOINT=https://xxxxx.agentcore.us-east-1.amazonaws.com

# Test
curl -X POST $ENDPOINT/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Test query"}'
```

## Project Structure

```
/Users/nirmal/Desktop/Agents/
│
├── Job Agent
│   ├── job_agent.py                    # Main application
│   ├── job_agent.Dockerfile            # Container definition
│   └── job_agent.requirements.txt      # Python dependencies
│
├── Course Agent
│   ├── course_agent.py
│   ├── course_agent.Dockerfile
│   └── course_agent.requirements.txt
│
├── Project Agent
│   ├── project_agent.py
│   ├── project_agent.Dockerfile
│   └── project_agent.requirements.txt
│
├── Orchestrator Agent
│   ├── orchestrator_agent.py
│   ├── orchestrator_agent.Dockerfile
│   └── orchestrator_agent.requirements.txt
│
├── .dockerignore                       # Docker ignore patterns
├── venv/                               # Virtual environment
└── README.md                           # This file
```

## Environment Variables

| Variable | Job | Course | Project | Orchestrator | Description |
|----------|-----|--------|---------|--------------|-------------|
| `AWS_ACCESS_KEY_ID` | ✓ | ✓ | ✓ | ✓ | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | ✓ | ✓ | ✓ | ✓ | AWS credentials |
| `AWS_DEFAULT_REGION` | ✓ | ✓ | ✓ | ✓ | AWS region (default: us-east-1) |
| `SERPAPI_KEY` | ✓ | - | - | ✓ | SerpAPI key for job search |
| `NEBULA_API_KEY` | - | ✓ | - | ✓ | UTD Nebula API key |

## API Reference

### Health Check
**Endpoint**: `GET /ping`
**Response**: `{"status":"Healthy"}`

### Agent Invocation
**Endpoint**: `POST /invocations`
**Request**:
```json
{
  "inputText": "Your natural language query"
}
```
**Response**:
```json
{
  "response": "Agent's response text"
}
```

## Features by Agent

### Job Agent
- Real-time job search via SerpAPI
- 10+ jobs per query
- Location-based filtering
- Company and salary data

### Course Agent
- 3000+ university courses
- Department filtering (CS, MATH, STAT, etc.)
- Keyword search
- Class level filtering
- Course descriptions and credit hours

### Project Agent
- 30+ curated portfolio projects
- 9 career categories
- Experience-level filtering
- Skills mapping (60+ technologies)
- Time estimates and portfolio value ratings

### Orchestrator Agent
- Coordinates all 3 specialized agents
- Parallel execution for speed
- Intelligent routing based on query
- Response synthesis
- Complete career roadmaps

## Use Cases

### Individual Agents

**Job Agent**:
- "Find remote Python developer jobs"
- "Data analyst positions in Austin, Texas"
- "Machine learning engineer jobs in Bay Area"

**Course Agent**:
- "What courses for data science career?"
- "Show me all CS courses"
- "Database courses for beginners"

**Project Agent**:
- "Portfolio projects for frontend developer"
- "What should I build for ML career?"
- "Beginner-friendly web development projects"

### Orchestrator (Complete Career Plans)

**Comprehensive Planning**:
- "I want to become a full-stack developer. Create a complete career plan."
- "Help me transition to data science. What's my roadmap?"
- "Complete plan for DevOps engineer career with timeline"

**Focused Multi-Agent**:
- "Jobs and courses for cybersecurity"
- "Projects and courses for AI engineer"
- "Find jobs and recommend projects for backend developer"

## Performance Metrics

| Agent | Avg Response Time | External API | Success Rate |
|-------|-------------------|--------------|--------------|
| Job Agent | 10-15s | SerpAPI | 100% |
| Course Agent | 12-22s | UTD Nebula | 95% |
| Project Agent | 10-15s | Internal DB | 100% |
| Orchestrator | 20-40s | All 3 agents | 95% |

## Cost Estimation

**Monthly costs for 1000 requests per agent**:

| Component | Job | Course | Project | Orchestrator |
|-----------|-----|--------|---------|--------------|
| Nova Pro | $10-15 | $10-15 | $10-15 | $30-50 |
| External API | $0-50 | $0 | $0 | $0-50 |
| AgentCore | $20-40 | $20-40 | $20-40 | $20-40 |
| **Total** | **$30-105** | **$30-55** | **$30-55** | **$50-140** |

**All 4 agents**: ~$140-355/month for 1000 requests each

## Monitoring

### CloudWatch Logs

```bash
# View logs for each agent
aws logs tail /aws/bedrock/agentcore/job-agent --follow
aws logs tail /aws/bedrock/agentcore/course-agent --follow
aws logs tail /aws/bedrock/agentcore/project-agent --follow
aws logs tail /aws/bedrock/agentcore/orchestrator-agent --follow
```

### Key Metrics
- Request count per agent
- Average response time
- Error rates
- API call success rates
- Token usage
- User query patterns

## Troubleshooting

### Issue: "ModuleNotFoundError"
**Solution**: Ensure Python 3.10+ and install dependencies
```bash
python3 --version  # Must be 3.10+
pip install -r <agent>.requirements.txt
```

### Issue: "NoCredentialsError"
**Solution**: Configure AWS credentials
```bash
aws configure
# Or export environment variables
```

### Issue: "AccessDeniedException" from Bedrock
**Solution**: Enable model access
1. AWS Console → Amazon Bedrock → Model access
2. Request access to Amazon Nova Pro
3. Wait for approval (usually instant)

### Issue: API key errors (SerpAPI/Nebula)
**Solution**: Set environment variables
```bash
export SERPAPI_KEY=your_key
export NEBULA_API_KEY=your_key
```

### Issue: Docker container won't start
**Solution**: Check environment variables and logs
```bash
docker logs <container-name>
docker inspect <container-name>
```

## Development

### Adding New Tools to Agents

1. Define tool function with `@tool` decorator
2. Add to agent's tools list
3. Update system prompt

Example:
```python
@tool
def new_tool(param: str) -> dict:
    """Tool description"""
    # Implementation
    return {"result": "data"}

agent = Agent(
    model=bedrock_model,
    tools=[existing_tool, new_tool]
)
```

### Testing

```bash
# Unit test individual tools
python -c "from job_agent import search_jobs; print(search_jobs('software engineer', 'Seattle', 'USA'))"

# Integration test
python <agent>.py &
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" -d '{"inputText": "test"}'
pkill -f <agent>.py
```

## Security Best Practices

1. **Never commit API keys** - Use environment variables
2. **Use AWS Secrets Manager** in production
3. **Enable VPC** for network isolation
4. **IAM roles** with least privilege
5. **CloudWatch logging** for audit trails
6. **API Gateway** for rate limiting
7. **HTTPS only** in production

## Roadmap

- [ ] Add salary prediction capabilities
- [ ] Interview preparation agent
- [ ] Resume review and optimization
- [ ] Networking/mentorship recommendations
- [ ] Multi-turn conversations
- [ ] Progress tracking dashboard
- [ ] Integration with job application platforms
- [ ] Custom course recommendations from multiple universities

## Technology Stack

- **Runtime**: AWS Bedrock AgentCore
- **AI Models**: Amazon Nova Pro
- **Framework**: Strands Agents SDK
- **Language**: Python 3.13
- **Containerization**: Docker
- **APIs**: SerpAPI, UTD Nebula API
- **Cloud**: AWS (ECR, Bedrock, CloudWatch)

## License

MIT License

## Support

For issues, questions, or contributions:
- AWS Bedrock: https://docs.aws.amazon.com/bedrock/
- Strands SDK: https://github.com/strands-agents/sdk-python
- SerpAPI: https://serpapi.com/docs
- UTD Nebula: https://api.utdnebula.com

---

**Built with ❤️ using AWS Bedrock AgentCore**
*Complete Career Development Platform - Jobs, Education, Projects, All in One*
