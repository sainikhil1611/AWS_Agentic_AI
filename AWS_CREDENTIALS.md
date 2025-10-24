# AWS Credentials Configuration

Your `aws configure` command is broken due to Python version conflicts. Here are alternative ways to configure AWS credentials:

## Method 1: Run the Helper Script (Easiest)

```bash
cd /Users/nirmal/Desktop/Agents
./configure_aws.sh
```

This will prompt you for your AWS credentials and create the necessary files.

## Method 2: Manually Create Credentials Files

### Step 1: Create the AWS directory
```bash
mkdir -p ~/.aws
```

### Step 2: Create credentials file
```bash
nano ~/.aws/credentials
```

Add the following (replace with your actual keys):
```
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID_HERE
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_HERE
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 3: Create config file
```bash
nano ~/.aws/config
```

Add the following:
```
[default]
region = us-east-1
output = json
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 4: Set proper permissions
```bash
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config
```

## Method 3: Use Environment Variables

Add these to your shell (in terminal or in `~/.zshrc` or `~/.bash_profile`):

```bash
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Where to Get AWS Credentials

1. Log in to AWS Console: https://console.aws.amazon.com/
2. Click your username (top right) → Security credentials
3. Under "Access keys", click "Create access key"
4. Copy the Access Key ID and Secret Access Key

**Important:** Save your Secret Access Key immediately - you won't be able to see it again!

## Verify Your Credentials

After configuring, test with:

```bash
cd /Users/nirmal/Desktop/Agents
source venv/bin/activate
python test_setup.py
```

## Enable Bedrock Model Access

Once credentials are working:

1. Go to AWS Console → Amazon Bedrock
2. Click "Model access" in the left sidebar
3. Click "Manage model access"
4. Find "Amazon Nova Pro" and check the box
5. Click "Request model access"
6. Wait for approval (usually instant for Nova models)

## Current Status

Your test showed:
- ✗ AWS Credentials - Invalid security token
- You need to configure valid AWS credentials using one of the methods above

Choose Method 1 (helper script) for the easiest setup!
