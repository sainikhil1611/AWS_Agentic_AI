# Career Orchestrator Agent - AWS Bedrock AgentCore

The master coordinator that brings together job search, course recommendations, and project suggestions into unified career development plans.

## Overview

The Orchestrator Agent is the crown jewel of this multi-agent system. It intelligently coordinates three specialized agents to create comprehensive, personalized career roadmaps powered by Amazon Nova Premier.

## Architecture

```
User Query
    ↓
Orchestrator Agent (Nova Premier)
    ↓
┌───────────┬─────────────┬──────────────┐
│ Job Agent │Course Agent │Project Agent │
│ (SerpAPI) │(UTD Nebula) │(Curated DB)  │
└───────────┴─────────────┴──────────────┘
    ↓           ↓              ↓
Synthesized Career Development Plan
```

## Features

- **Multi-Agent Orchestration**: Coordinates 3 specialized agents
- **Amazon Nova Premier**: Most advanced model for strategic planning
- **Intelligent Routing**: Decides which agents to call based on query
- **Response Synthesis**: Merges outputs into cohesive career plans
- **Complete Career Roadmaps**: Jobs + Education + Portfolio in one response

## Quick Start

### Local Development

1. **Prerequisites**
   - Python 3.10+
   - AWS credentials with Bedrock Nova Premier access
   - SerpAPI key
   - Nebula API key

2. **Setup**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r orchestrator_requirements.txt

   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   export AWS_DEFAULT_REGION=us-east-1
   export SERPAPI_KEY=your_key
   export NEBULA_API_KEY=your_key
   ```

3. **Run**
   ```bash
   python orchestrator_agent.py
   ```

4. **Test**
   ```bash
   curl -X POST http://localhost:8080/invocations \
     -H "Content-Type: application/json" \
     -d '{"inputText": "I want to become a machine learning engineer. Create a complete career plan."}'
   ```

## Example Queries

### Comprehensive Career Plans
```json
{"inputText": "I want to become a full-stack developer. Create a complete career plan."}
{"inputText": "Help me transition to data science. What's my roadmap?"}
{"inputText": "I want to work in AI/ML. Give me a complete plan."}
```

### Focused Queries
```json
{"inputText": "What jobs and courses for DevOps engineer?"}
{"inputText": "Show me projects and courses for frontend developer"}
{"inputText": "Find jobs and recommend portfolio projects for data analyst"}
```

## Available Tools

### query_job_agent
Finds job opportunities in the current market.

**Parameters:**
- `job_query`: Natural language job search query

**Example:**
```python
query_job_agent("Find machine learning engineer jobs in San Francisco")
```

**Returns:**
- Job listings with title, company, location, description
- Job market insights

### query_course_agent
Recommends university courses from UTD.

**Parameters:**
- `course_query`: Natural language course request

**Example:**
```python
query_course_agent("What courses for machine learning and data science?")
```

**Returns:**
- Course codes, titles, descriptions
- Credit hours and difficulty levels

### query_project_agent
Suggests portfolio-ready projects.

**Parameters:**
- `project_query`: Natural language project request

**Example:**
```python
query_project_agent("Portfolio projects for ML engineer career")
```

**Returns:**
- Project recommendations with skills, duration, value
- Implementation guidance

## Orchestration Strategy

### Decision Tree

```
User Query Analysis
    │
    ├─ Contains "career plan"? → Call ALL 3 agents
    │
    ├─ Contains "jobs"? → Call job_agent
    │   └─ Also mentions "learn"? → + course_agent
    │
    ├─ Contains "courses"? → Call course_agent
    │   └─ Also mentions "build"? → + project_agent
    │
    └─ Contains "projects"? → Call project_agent
        └─ Also mentions "job"? → + job_agent
```

### Response Synthesis

The orchestrator combines outputs into sections:

1. **Executive Summary**: High-level career strategy
2. **Job Market Overview**: Current opportunities
3. **Learning Path**: Recommended courses
4. **Portfolio Strategy**: Project recommendations
5. **Timeline**: Suggested milestones
6. **Next Steps**: Action items

## Docker Deployment

### Build Image

```bash
docker build -f orchestrator.Dockerfile -t orchestrator-agent .
```

### Run Container

```bash
docker run -d \
  -p 8080:8080 \
  -e AWS_ACCESS_KEY_ID=your_key \
  -e AWS_SECRET_ACCESS_KEY=your_secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e SERPAPI_KEY=your_key \
  -e NEBULA_API_KEY=your_key \
  --name orchestrator-agent \
  orchestrator-agent
```

## AWS Bedrock AgentCore Deployment

### Quick Deploy

```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1

# Build and push
docker build -f orchestrator.Dockerfile -t orchestrator-agent .
aws ecr create-repository --repository-name orchestrator-agent --region $AWS_REGION
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag orchestrator-agent:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/orchestrator-agent:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/orchestrator-agent:latest
```

### Deploy via Console

1. AWS Console → Bedrock → AgentCore
2. Create runtime: `orchestrator-agent`
3. Image URI: (from above)
4. Environment variables: SERPAPI_KEY, NEBULA_API_KEY
5. **Important**: Request access to Nova Premier model first!

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS credentials | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials | Yes |
| `AWS_DEFAULT_REGION` | AWS region | No (default: us-east-1) |
| `SERPAPI_KEY` | SerpAPI key | Yes |
| `NEBULA_API_KEY` | UTD Nebula API key | Yes |
| `JOB_AGENT_URL` | Job agent endpoint | No (uses inline) |
| `COURSE_AGENT_URL` | Course agent endpoint | No (uses inline) |
| `PROJECT_AGENT_URL` | Project agent endpoint | No (uses inline) |

## Sample Career Plan Output

```
EXECUTIVE SUMMARY
================
Based on your goal to become a machine learning engineer, here's your comprehensive career development plan combining education, portfolio building, and job search.

JOB MARKET OVERVIEW
==================
Current opportunities for ML engineers:
- Google - ML Engineer, Mountain View ($180K-250K)
- Meta - Machine Learning Engineer, Menlo Park ($175K-240K)
- Amazon - Applied Scientist, Seattle ($165K-220K)
[10 jobs total]

LEARNING PATH
=============
Recommended courses at UTD:
1. CS 4395 - Introduction to Machine Learning (3 credits)
2. BUAN 4382 - Applied AI/Machine Learning (3 credits)
3. ACN 6349 - Statistical Machine Learning (3 credits)
4. CS 4347 - Database Systems (3 credits)
[15 courses total]

PORTFOLIO STRATEGY
==================
Build these 3 projects to demonstrate ML expertise:

1. Recommendation Engine (4-5 weeks)
   - Skills: ML algorithms, Python, Neural networks
   - Why: Industry-standard application, shows end-to-end ML

2. Predictive Analytics Dashboard (5-7 weeks)
   - Skills: TensorFlow, Pandas, Visualization
   - Why: Combines ML with business value communication

3. Sentiment Analysis Tool (3-4 weeks)
   - Skills: NLP, Python, API development
   - Why: Demonstrates NLP capabilities

TIMELINE
========
- Months 1-2: Take CS 4395, start Recommendation Engine
- Months 3-4: Complete project 1, take BUAN 4382, start project 2
- Months 5-6: Finish project 2, take ACN 6349, start project 3
- Month 7: Complete portfolio, polish resume
- Month 8: Apply to jobs, interview prep

NEXT STEPS
==========
1. Enroll in CS 4395 for next semester
2. Set up development environment for ML projects
3. Create GitHub account and portfolio website
4. Start building Recommendation Engine
5. Network with ML professionals on LinkedIn
```

## Performance

| Metric | Value |
|--------|-------|
| Average Response Time | 25-40 seconds |
| Agents Called | 1-3 per query |
| Success Rate | >95% |
| Model | Nova Premier (most advanced) |

## Cost Estimation

**Monthly costs for 1000 comprehensive plans:**

- Nova Premier: $50-80 (higher cost, better quality)
- SerpAPI: $0-50
- Nebula API: Free
- AgentCore Runtime: $20-40
- **Total**: ~$70-170/month

*Note: Nova Premier is premium but provides superior orchestration*

## Advantages Over Single Agents

| Aspect | Single Agent | Orchestrator |
|--------|-------------|--------------|
| **Coverage** | One domain | Complete career plan |
| **Context** | Limited | Cross-domain insights |
| **Actionability** | Partial | End-to-end roadmap |
| **Intelligence** | Good | Excellent (Nova Premier) |
| **User Experience** | Multiple queries | One query |

## Monitoring

```bash
# View logs
aws logs tail /aws/bedrock/agentcore/orchestrator-agent --follow

# Key metrics
- Agent call distribution
- Response synthesis quality
- User satisfaction scores
- Average plan completeness
```

## Troubleshooting

### Issue: Incomplete career plans

**Solution**: Ensure query clearly states career goal
- Bad: "Help me"
- Good: "I want to become a data scientist, create a complete plan"

### Issue: Agent timeout

**Solution**:
- Query is too broad - be more specific
- Check network connectivity to sub-agents
- Increase timeout in configuration

### Issue: Missing Nova Premier access

**Solution**:
1. AWS Console → Bedrock → Model access
2. Request access to Nova Premier
3. Wait for approval (may take longer than other models)

## Best Practices

1. **Clear Career Goals**: Specify target role explicitly
2. **Comprehensive Queries**: Ask for "complete plan" to trigger all agents
3. **Follow Timeline**: Use generated timeline for accountability
4. **Update Progress**: Re-query as you complete milestones
5. **Leverage Insights**: Use job market data to prioritize learning

## Development

### Project Structure

```
orchestrator_agent.py           # Main orchestrator
├── query_job_agent()          # Job search coordination
├── query_course_agent()       # Course recommendation coordination
└── query_project_agent()      # Project suggestion coordination
```

### Adding New Agents

To add a fourth specialized agent:

1. Create new tool function:
```python
@tool
def query_new_agent(query: str) -> Dict:
    # Implementation
    pass
```

2. Update orchestrator system prompt
3. Add to agent tools list

## Testing

```bash
# Start orchestrator
python orchestrator_agent.py &

# Test comprehensive plan
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Full career plan for data science"}'

# Test focused query
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Jobs and courses for ML engineer"}'
```

## Roadmap

- [ ] Add salary prediction agent
- [ ] Include interview preparation agent
- [ ] Add networking/mentorship recommendations
- [ ] Integrate resume review capabilities
- [ ] Add career progression tracking
- [ ] Multi-turn conversation support

## License

MIT License

---

**The ultimate career development platform powered by AWS Bedrock AgentCore** 🚀
