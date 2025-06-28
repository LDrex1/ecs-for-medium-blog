#! /usr/bin/bash
FILENAME="$1"

if [[ -z "$FILENAME" ]]; then
    echo "Usage: $0 <plan-name>"
    echo "Please give the name of the file to save the plan"
    exit 1
fi

if [[ ! $FILENAME =~ ^[a-z]{3,}[0-9]*$ ]]; then
    echo "Invalid filename: '$FILENAME'"
    echo "Filename should start with at least 3 lowercase letters and may end with a number"
    exit 1
fi

# Creat binary plan
terraform plan -out="$FILENAME"
terraform show -no-color "$FILENAME" >"${FILENAME}".txt

echo "Plan saved to '$FILENAME' and readable format saved to '${FILENAME}.txt'"
