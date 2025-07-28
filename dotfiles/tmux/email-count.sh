#!/usr/bin/env bash
# Get unread email count from Mail.app

# Check if Mail.app is running
if ! pgrep -x "Mail" > /dev/null; then
    echo "0"
    exit 0
fi

# Get unread count from Mail.app
count=$(osascript -e 'tell application "Mail" to return the unread count of inbox' 2>/dev/null)

# Handle errors or empty results
if [ -z "$count" ] || [ "$count" = "missing value" ]; then
    echo "0"
else
    echo "$count"
fi