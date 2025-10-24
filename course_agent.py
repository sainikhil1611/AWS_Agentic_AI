"""
Course Recommendation Agent
---------------------------------
Uses AWS Bedrock AgentCore with Strands framework to recommend university courses
based on a user's career goals.
"""

from bedrock_agentcore import BedrockAgentCoreApp
from strands import Agent, tool
from strands.models import BedrockModel
from fastapi import FastAPI, Request
import json
import urllib.request
import urllib.error
import logging
import os
from dotenv import load_dotenv

# =========================================================
# Environment and Logging Setup
# =========================================================

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# =========================================================
# Configuration
# =========================================================
NEBULA_API_KEY = os.getenv("NEBULA_API_KEY")
NEBULA_BASE_URL = os.getenv("NEBULA_BASE_URL", "https://api.utdnebula.com")
AWS_REGION = os.getenv("AWS_DEFAULT_REGION", "us-east-1")
MAX_DESC_LENGTH = 250

if not NEBULA_API_KEY:
    raise ValueError("AIzaSyC2MbNxOIBgRf3ebgj6QGYUJtHzVV1so_Y")

# =========================================================
# Initialize Bedrock AgentCore + FastAPI
# =========================================================
app = BedrockAgentCoreApp()
fastapi_app = FastAPI(title="Course Recommendation Agent")

# =========================================================
# Helper Function
# =========================================================
def truncate(text, length=MAX_DESC_LENGTH):
    """Truncate text safely"""
    if not text:
        return ""
    text = text.strip()
    return text if len(text) <= length else text[:length].rstrip() + "..."

# =========================================================
# Tools
# =====================================================
