#!/usr/bin/bash

usage() {
    cat <<EOF
Usage: $0 <github-repo-slug>
"Example: $0 user/repository"

Checks for .env files and uploads the keys securely to github

Arguments:
    github repo: github repository where the secrets are to be used
    
EOF
    exit 1
}

# Ensures that the Github slug repository is provided in command. If not provided, this block will run
if [ -z "$1" ]; then
    echo "Usage: $0 <github-repo-slug>"
    echo "Example: $0 user/repository"
    exit 1
fi
# Save the value of Github repo slug
REPO=$1

# Check if .env file exists
if [ ! -f .env ] && [ ! -f .env.local ]; then
    echo "Error: .env or .env.local file not found"
    exit 1
fi
# If both .env and .env.local exists, choose the .env file
if [ -f .env ] && [ -f .env.local ]; then
    echo "Warning: .env and .env.local both exist"
    echo "Warning: will be using the .env file"
    ENV_FILE=".env"
else
    # Check and store the type of env file that exists
    if [ -f .env.local ]; then
        ENV_FILE=".env.local"
    elif [ -f .env ]; then
        ENV_FILE=".env"
    fi
fi

# Loop through each line with no field spliting in the .env file
while IFS= read -r line || [ -n "${line}" ]; do

    # Skip empty lines and comments
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    # Skip invalid line that do not have a key=value format
    if [[ "$line" != *=* ]]; then
        echo "Warning: skipping invalid line: $line"
        continue
    fi
    # Extract the key and value
    IFS="=" read -r key value <<<"${line}"

    # Trim possible quotes around the value
    value=$(echo "${value}" | sed 's/^"//;s/"$//')

    #Set the Github secret using the Github CLI command
    gh secret set "$key" --body "$value" --repo "$REPO"

    # Capture the exit status of the gh command
    if [ $? -ne 0 ]; then
        # Check if the error is a 404 (repository not found or permission issue)
        echo "Error: Failed to set secret for key '$key'. Checking for potential issues..."

        # Check if it's the 404 error
        gh secret list --repo "$REPO" &>/dev/null
        if [ $? -eq 404 ]; then
            echo "Error: HTTP 404 Not Found. The repository '$REPO' may not exist or you may not have the necessary permissions."
            exit 1
        else
            echo "Error: Failed to set the secret for key '$key'. Please check your GitHub repository slug and access permissions."
            exit 1
        fi
    fi
done <"$ENV_FILE"

echo "Success: All secrets have been set." # Success message
