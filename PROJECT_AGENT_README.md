# Project Recommendation Agent - AWS Bedrock AgentCore

An intelligent project recommendation agent built with AWS Bedrock AgentCore and Strands framework, powered by Amazon Nova Pro. Recommends 3 portfolio-ready projects and skills to acquire based on career goals.

## Features

- **AI-Powered Recommendations**: Uses Amazon Nova Pro for intelligent project matching
- **Curated Project Database**: 30+ hand-selected, portfolio-worthy projects
- **Skills Mapping**: Comprehensive skill recommendations by career path
- **Career-Focused**: Tailored to specific roles and experience levels
- **Portfolio Strategy**: Helps build competitive portfolios for job hunting
- **Production-Ready**: Built on AWS Bedrock AgentCore for enterprise deployment

## Architecture

```
User Career Goal → BedrockAgentCore → Strands Agent (Nova Pro) → Project/Skill Tools → Curated DB → Recommendations
```

## Quick Start

### Local Development

1. **Prerequisites**
   - Python 3.10+
   - AWS credentials with Bedrock access

2. **Setup**
   ```bash
   # Create virtual environment
   python3 -m venv venv
   source venv/bin/activate

   # Install dependencies
   pip install -r project_requirements.txt

   # Configure AWS credentials
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   export AWS_DEFAULT_REGION=us-east-1
   ```

3. **Run**
   ```bash
   python project_agent.py
   ```

4. **Test**
   ```bash
   # Health check
   curl http://localhost:8080/ping

   # Project recommendations
   curl -X POST http://localhost:8080/invocations \
     -H "Content-Type: application/json" \
     -d '{"inputText": "I want to become a machine learning engineer. What projects should I build?"}'
   ```

## Example Queries

The agent understands natural language queries about career goals:

### Career-Based Queries
```json
{"inputText": "What projects should I build to become a full-stack developer?"}
{"inputText": "I want to work in machine learning. Recommend portfolio projects"}
{"inputText": "Projects for data science career"}
{"inputText": "What should I build for a DevOps role?"}
{"inputText": "Recommend projects for blockchain development"}
```

### Experience-Level Queries
```json
{"inputText": "Beginner-friendly projects for web development"}
{"inputText": "Advanced projects for AI engineer portfolio"}
{"inputText": "Intermediate level cybersecurity projects"}
```

### Skills-Focused Queries
```json
{"inputText": "What skills do I need to become a frontend developer?"}
{"inputText": "Skills required for data science career"}
{"inputText": "What should I learn for cloud engineering?"}
```

## Project Categories

The agent draws from a curated database of projects across 9 categories:

### 1. Web Development
- E-Commerce Platform
- Social Media Dashboard
- Real-Time Chat Application

### 2. Mobile Development
- Fitness Tracking App
- Expense Tracker

### 3. Data Science
- Predictive Analytics Dashboard
- Sentiment Analysis Tool
- Image Classification System

### 4. Machine Learning
- Recommendation Engine
- Fraud Detection System

### 5. Cloud & DevOps
- Microservices Architecture
- Infrastructure as Code Platform

### 6. Cybersecurity
- Security Vulnerability Scanner
- Password Manager

### 7. AI & LLMs
- RAG-Based Chatbot
- AI Code Assistant

### 8. Blockchain
- NFT Marketplace
- DeFi Yield Aggregator

### 9. General
- Portfolio Website with CMS
- CLI Tool for Developers

## Skills Database

Organized by category:
- **Frontend**: React, Vue.js, TypeScript, Tailwind CSS, Next.js
- **Backend**: Node.js, Python, Java Spring, Go, GraphQL
- **Database**: PostgreSQL, MongoDB, Redis, optimization
- **DevOps**: Docker, Kubernetes, CI/CD, AWS, Terraform
- **ML/AI**: TensorFlow, PyTorch, NLP, LLMs, RAG, MLOps
- **Mobile**: React Native, Flutter, iOS, Android
- **Security**: OWASP, Cryptography, Pentesting
- **Blockchain**: Solidity, Web3, Smart Contracts, DeFi
- **Soft Skills**: Git, Agile, Documentation, Testing

## Docker Deployment

### Build Image

```bash
docker build -f project.Dockerfile -t project-agent .
```

### Run Container

```bash
docker run -d \
  -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  --name project-agent \
  project-agent
```

### Test Container

```bash
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Projects for data engineer role?"}'
```

## AWS Bedrock AgentCore Deployment

### Quick Deploy

```bash
# Set variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1
export AGENT_NAME=project-agent

# Build and push to ECR
docker build -f project.Dockerfile -t $AGENT_NAME .
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
   - **Name**: `project-agent`
   - **Image URI**: (from above)
   - **Port**: `8080`
   - **vCPU**: 0.5, **Memory**: 1 GB
4. Click **Create runtime**

## Available Tools

### get_project_recommendations

Recommends 3 portfolio-ready projects based on career goal.

**Parameters:**
- `career_goal` (required): Target role (e.g., "full-stack developer", "ML engineer")
- `experience_level` (optional): "beginner", "intermediate", "advanced" (default: "intermediate")

**Returns:**
- 3 curated projects with name, description, skills, difficulty, duration, portfolio value

**Example:**
```python
get_project_recommendations(
    career_goal="machine learning engineer",
    experience_level="advanced"
)
```

### get_skill_recommendations

Recommends skills to acquire for a career goal.

**Parameters:**
- `career_goal` (required): Target role
- `skill_categories` (optional): Specific categories to focus on

**Returns:**
- Skills organized by category with learning priorities

**Example:**
```python
get_skill_recommendations(
    career_goal="full-stack developer",
    skill_categories=["frontend", "backend", "database"]
)
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Yes | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes | - |
| `AWS_DEFAULT_REGION` | AWS region | No | us-east-1 |

## API Reference

### Health Check

**Endpoint**: `GET /ping`

**Response**:
```json
{"status":"Healthy"}
```

### Project Recommendations

**Endpoint**: `POST /invocations`

**Request**:
```json
{
  "inputText": "I want to become a full-stack developer. What projects should I build?"
}
```

**Response**:
```json
{
  "response": "Based on your goal to become a full-stack developer, here are 3 portfolio-ready projects:\n\n**1. E-Commerce Platform**\n- Description: Full-stack site with catalog, cart, checkout...\n- Skills: React, Node.js, PostgreSQL, Stripe API\n- Difficulty: Intermediate\n- Duration: 4-6 weeks\n- Why valuable: Demonstrates full-stack capabilities...\n\n**2. Real-Time Chat Application**\n...\n\n**3. Portfolio Website with CMS**\n...\n\n**Key Skills to Develop:**\n- Frontend: React, TypeScript, Tailwind CSS\n- Backend: Node.js, RESTful APIs, GraphQL\n- Database: PostgreSQL, database design\n..."
}
```

## Career Path Examples

### Full-Stack Developer
**Recommended Projects:**
1. E-Commerce Platform
2. Social Media Dashboard
3. Real-Time Chat Application

**Key Skills:**
- Frontend: React, TypeScript
- Backend: Node.js, APIs
- Database: PostgreSQL
- DevOps: Docker, CI/CD

### Machine Learning Engineer
**Recommended Projects:**
1. Recommendation Engine
2. Fraud Detection System
3. Predictive Analytics Dashboard

**Key Skills:**
- ML: TensorFlow, PyTorch
- Python: Pandas, NumPy, Scikit-learn
- MLOps: Model deployment, monitoring
- Data: Feature engineering, pipelines

### DevOps Engineer
**Recommended Projects:**
1. Microservices Architecture
2. Infrastructure as Code Platform
3. CI/CD Pipeline Automation

**Key Skills:**
- Containers: Docker, Kubernetes
- Cloud: AWS/Azure/GCP
- IaC: Terraform, CloudFormation
- CI/CD: Jenkins, GitHub Actions

## Project Difficulty Levels

| Level | Description | Expected Skills |
|-------|-------------|-----------------|
| **Beginner** | 2-3 weeks, basic concepts | Core language, basic frameworks |
| **Beginner-Intermediate** | 2-4 weeks, some complexity | Multiple technologies, APIs |
| **Intermediate** | 3-5 weeks, full-featured apps | Advanced frameworks, databases |
| **Intermediate-Advanced** | 4-6 weeks, complex systems | Architecture, optimization |
| **Advanced** | 5-9 weeks, production-grade | Advanced concepts, best practices |

## Portfolio Value

| Value | Impact | Examples |
|-------|--------|----------|
| **Very High** | Exceptional portfolio piece | ML systems, blockchain apps, RAG chatbots |
| **High** | Strong demonstration of skills | Full-stack apps, microservices |
| **Medium-High** | Solid project, good learning | Mobile apps, security tools |
| **Medium** | Good foundation project | Portfolio sites, CLI tools |

## Monitoring

### View Logs

```bash
# Local Docker
docker logs project-agent -f

# AWS CloudWatch
aws logs tail /aws/bedrock/agentcore/project-agent --follow
```

### Key Metrics

- Request count
- Response quality
- Average response time
- Project category distribution
- Career goal patterns

## Troubleshooting

### Issue: Generic recommendations

**Solution**: Be more specific in query
- Instead of: "What projects should I build?"
- Try: "What projects should I build to become a machine learning engineer?"

### Issue: Wrong difficulty level

**Solution**: Specify experience level explicitly
```
"Beginner-friendly projects for web development"
"Advanced projects for experienced developer"
```

## Cost Optimization

- **Amazon Nova Pro**: ~$0.0008 per 1K input tokens
- **AgentCore Runtime**: Based on usage (vCPU-hours)
- **No external APIs**: All data from curated database

Estimated cost for 1000 requests/day: ~$5-15/month

## Development

### Project Structure

```
.
├── project_agent.py              # Main application
├── project_requirements.txt      # Dependencies
├── project.Dockerfile           # Container definition
└── PROJECT_AGENT_README.md      # This file
```

### Adding New Projects

Edit `PROJECT_DATABASE` in project_agent.py:

```python
PROJECT_DATABASE = {
    "your_category": [
        {
            "name": "Project Name",
            "description": "Detailed description",
            "skills": ["Skill 1", "Skill 2"],
            "difficulty": "Intermediate",
            "duration": "3-4 weeks",
            "portfolio_value": "High - Why it's valuable"
        }
    ]
}
```

### Adding New Skills

Edit `SKILLS_DATABASE` in project_agent.py:

```python
SKILLS_DATABASE = {
    "your_category": ["Skill 1", "Skill 2", "Skill 3"]
}
```

## Testing

### Unit Tests

```bash
# Test project recommendations
python -c "from project_agent import get_project_recommendations; print(get_project_recommendations('full-stack developer', 'intermediate'))"

# Test skill recommendations
python -c "from project_agent import get_skill_recommendations; print(get_skill_recommendations('data scientist'))"
```

### Integration Tests

```bash
# Start agent
python project_agent.py &
sleep 3

# Test various queries
curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "Full-stack projects"}'

curl -X POST http://localhost:8080/invocations -H "Content-Type: application/json" \
  -d '{"inputText": "ML engineer skills"}'

# Stop agent
pkill -f project_agent.py
```

## Roadmap

- [ ] Add project templates/starter code links
- [ ] Include learning resource recommendations
- [ ] Add project completion checklist
- [ ] Integrate with GitHub for project tracking
- [ ] Add difficulty progression paths
- [ ] Include estimated learning hours
- [ ] Add project showcase examples

## Support

- **AWS Bedrock**: https://docs.aws.amazon.com/bedrock/
- **Strands SDK**: https://github.com/strands-agents/sdk-python

## License

MIT License

---

Built with ❤️ using AWS Bedrock AgentCore - Help developers build amazing portfolios!
