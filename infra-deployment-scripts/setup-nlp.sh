#!/bin/bash

# Script to enable NLP sentiment and create an API key

# Prompt user for project ID
read -p "Enter your Google Cloud project ID: " project_id

# Verify if project ID is provided
if [[ -z "$project_id" ]]; then
    echo "Error: Please provide your project ID."
    exit 1
fi

# Confirm project ID with user
echo "You've entered the project ID: $project_id"
read -p "Is this correct? (y/n): " confirm_project_id

# Verify if user confirms project ID
if [[ "$confirm_project_id" != "y" ]]; then
    echo "Please rerun the script and provide the correct project ID."
    exit 1
fi

# Set the current project
gcloud config set project "$project_id"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to set project ID."
    exit 1
fi

# Enable the Google Cloud NLP (Natural Language Processing) service
gcloud services enable "language.googleapis.com"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to enable $service_name."
    exit 1
fi

# Create an API key for accessing the NLP service
api_key_output=$(gcloud services api-keys create --display-name="Sentiment Github Action" --api-target=service="language.googleapis.com" --quiet --format=json)
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create API key."
    exit 1
fi

# Extract the API key from the JSON output
api_key=$(echo "$api_key_output" | jq -r '.response.keyString')

# Display the API key (you may want to handle it securely in your workflow)
echo -e "\n\n\n\nAPI key created successfully: $api_key"
