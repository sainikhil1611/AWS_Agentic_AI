# AWS Bedrock AgentCore - Dual Agent System

This repository contains two production-ready AI agents built with AWS Bedrock AgentCore and Strands framework.

## 📦 Agents Overview

### 1. Job Search Agent
**Purpose**: Find job opportunities based on user preferences
**File**: [agent.py](agent.py)
**Status**: ✅ Deployed and tested

**Features**:
- AI-powered job search using SerpAPI
- Natural language query understanding
- Location-based job filtering
- Real-time job listings

**Example Query**:
```
"Find software engineer jobs in Seattle"
```

### 2. Course Recommendation Agent
**Purpose**: Recommend university courses based on career goals
**File**: [course_agent.py](course_agent.py)
**Status**: ✅ Ready for deployment

**Features**:
- Career-to-course mapping using AI
- Real-time UTD course data
- Department and keyword search
- Structured learning path recommendations

**Example Query**:
```
"What courses should I take to become a machine learning engineer?"
```

## 📁 Project Structure

```
/Users/nirmal/Desktop/Agents/
│
├── 🎯 Job Search Agent
│   ├── agent.py                    # Main job agent
│   ├── requirements.txt            # Dependencies
│   ├── Dockerfile                  # Container
│   ├── README.md                   # Full documentation
│   ├── DEPLOYMENT.md              # Deploy guide
│   └── QUICKSTART_DEPLOY.md       # Quick deploy
│
├── 🎓 Course Recommendation Agent
│   ├── course_agent.py            # Main course agent
│   ├── course_requirements.txt    # Dependencies
│   ├── course.Dockerfile          # Container
│   ├── COURSE_AGENT_README.md     # Full documentation
│   └── COURSE_DEPLOY.md           # Deploy guide
│
└── 📚 Shared Documentation
    ├── AWS_CREDENTIALS.md         # AWS setup
    ├── SETUP.md                   # Local setup
    ├── TESTING.md                 # Testing guide
    └── AGENTS_OVERVIEW.md         # This file
```

## 🚀 Quick Deployment

### Job Search Agent

```bash
# Build
docker build -t job-search-agent .

# Push to ECR
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository --repository-name job-search-agent --region us-east-1
docker tag job-search-agent:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/job-search-agent:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/job-search-agent:latest

# Deploy via AWS Console → Bedrock → AgentCore
```

### Course Recommendation Agent

```bash
# Build
docker build -f course.Dockerfile -t course-agent .

# Push to ECR
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository --repository-name course-agent --region us-east-1
docker tag course-agent:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/course-agent:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/course-agent:latest

# Deploy via AWS Console → Bedrock → AgentCore
```

## 🔧 Environment Variables

### Job Search Agent
| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Yes | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Yes | AWS credentials |
| `AWS_DEFAULT_REGION` | No | Default: us-east-1 |
| `SERPAPI_KEY` | No | Has default value |

### Course Recommendation Agent
| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Yes | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Yes | AWS credentials |
| `AWS_DEFAULT_REGION` | No | Default: us-east-1 |
| `NEBULA_API_KEY` | Yes | UTD Nebula API key |

## 🧪 Testing Locally

### Job Search Agent
```bash
# Terminal 1: Run agent
cd /Users/nirmal/Desktop/Agents
source venv/bin/activate
python agent.py

# Terminal 2: Test
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Find data scientist jobs in San Francisco"}'
```

### Course Recommendation Agent
```bash
# Terminal 1: Run agent
cd /Users/nirmal/Desktop/Agents
source venv/bin/activate
export NEBULA_API_KEY=your_key
python course_agent.py

# Terminal 2: Test
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Courses for software engineering?"}'
```

## 📊 Comparison

| Feature | Job Search Agent | Course Agent |
|---------|-----------------|--------------|
| **Model** | Amazon Nova Pro | Amazon Nova Pro |
| **Framework** | Strands | Strands |
| **Runtime** | AgentCore | AgentCore |
| **External API** | SerpAPI | UTD Nebula |
| **Primary Tool** | search_jobs | get_courses_by_department |
| **Secondary Tool** | - | search_courses_by_keyword |
| **Port** | 8080 | 8080 |
| **Docker File** | Dockerfile | course.Dockerfile |

## 🎯 Use Cases

### Job Search Agent
- Career counseling services
- Job boards and recruitment platforms
- University career centers
- Job market research
- Remote work opportunity discovery

### Course Recommendation Agent
- Academic advising systems
- Degree planning tools
- Career path exploration
- Course catalog search
- Curriculum recommendations

## 🔄 Integration Possibilities

### Combined Workflow
1. **User**: "I want to be a data scientist"
2. **Course Agent**: Recommends MATH, STAT, CS courses
3. **User**: Takes recommended courses
4. **Job Search Agent**: Finds data scientist positions
5. **Result**: Complete career path from education to employment

### Multi-Agent Architecture
```
User Query
    ↓
Agent Router
    ↓
    ├─→ Course Agent (education-related)
    └─→ Job Agent (employment-related)
```

## 💰 Cost Estimation

### Per 10,000 Requests/Month

| Component | Job Agent | Course Agent | Both |
|-----------|-----------|--------------|------|
| AgentCore Runtime | $20-40 | $20-40 | $40-80 |
| Amazon Nova Pro | $10-15 | $10-15 | $20-30 |
| External API | $0-50 | $0 | $0-50 |
| **Total** | **$30-105** | **$30-55** | **$60-160** |

## 📈 Monitoring

### CloudWatch Metrics
```bash
# Job agent logs
aws logs tail /aws/bedrock/agentcore/job-search-agent --follow

# Course agent logs
aws logs tail /aws/bedrock/agentcore/course-agent --follow
```

### Key Metrics to Track
- Request count per agent
- Response latency
- Error rates
- API call success rates
- Token usage (Nova Pro)

## 🛠️ Development Workflow

### Adding a New Agent

1. **Create agent file** (e.g., `new_agent.py`)
2. **Define tools** with `@tool` decorator
3. **Configure Strands agent** with system prompt
4. **Create Dockerfile** (e.g., `new.Dockerfile`)
5. **Write documentation**
6. **Test locally**
7. **Deploy to ECR**
8. **Deploy to AgentCore**

### Best Practices
- ✅ Use descriptive tool names
- ✅ Add comprehensive docstrings
- ✅ Implement error handling
- ✅ Log important events
- ✅ Set appropriate timeouts
- ✅ Limit API response sizes
- ✅ Use environment variables for secrets

## 🔒 Security Checklist

- [ ] Never commit API keys
- [ ] Use AWS Secrets Manager for production
- [ ] Enable VPC for network isolation
- [ ] Configure IAM roles with least privilege
- [ ] Enable CloudWatch logging
- [ ] Set up API Gateway for rate limiting
- [ ] Use HTTPS only
- [ ] Implement request validation
- [ ] Monitor for anomalous usage

## 📚 Documentation Index

### Job Search Agent
- [README.md](README.md) - Complete documentation
- [DEPLOYMENT.md](DEPLOYMENT.md) - Detailed deployment guide
- [QUICKSTART_DEPLOY.md](QUICKSTART_DEPLOY.md) - Quick deploy

### Course Recommendation Agent
- [COURSE_AGENT_README.md](COURSE_AGENT_README.md) - Complete documentation
- [COURSE_DEPLOY.md](COURSE_DEPLOY.md) - Deployment guide

### General
- [AWS_CREDENTIALS.md](AWS_CREDENTIALS.md) - AWS setup
- [SETUP.md](SETUP.md) - Local development setup
- [TESTING.md](TESTING.md) - Testing guide

## 🎓 Learning Resources

- [AWS Bedrock AgentCore Docs](https://docs.aws.amazon.com/bedrock/latest/userguide/agentcore.html)
- [Strands SDK Documentation](https://github.com/strands-agents/sdk-python)
- [Amazon Nova Models](https://aws.amazon.com/bedrock/nova/)
- [SerpAPI Documentation](https://serpapi.com/docs)
- [UTD Nebula API](https://api.utdnebula.com)

## 🤝 Contributing

To add a new agent to this system:
1. Follow the structure of existing agents
2. Use the same Strands + AgentCore pattern
3. Add comprehensive documentation
4. Test locally before deploying
5. Update this overview document

## 📄 License

MIT License

---

Built with ❤️ using AWS Bedrock AgentCore, Strands Framework, and Amazon Nova Pro
