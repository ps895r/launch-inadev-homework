#!/bin/bash
DNS_NAME=$1
echo $DNS_NAME
# Replace these placeholders with your actual values
ACCESS_TOKEN="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"
REPO_OWNER="ps895r"
REPO_NAME="inadev-weather"
JENKINS_URL="http://$DNS_NAME:8080/"
JENKINS_JOB="GetWeather"

# Set the webhook URL
##WEBHOOK_URL="${JENKINS_URL}/github-webhook/${REPO_OWNER}/${REPO_NAME}"
WEBHOOK_URL="${JENKINS_URL}github-webhook/"
# GitHub API endpoint for creating a webhook
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks"

# JSON payload for creating a webhook
PAYLOAD=$(cat <<EOF
{
  "name": "web",
  "active": true,
  "events": ["push"],
  "config": {
    "url": "${WEBHOOK_URL}",
    "content_type": "json",
    "secret": ""
  }
}
EOF
)

# Make the API request to create the webhook
curl -X POST \
  -H "Authorization: token ${ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "${API_URL}" \
  -d "${PAYLOAD}"

