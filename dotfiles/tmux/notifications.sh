#!/usr/bin/env bash
# Combined notification display for tmux status bar

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get counts from individual scripts
email_count=$("$SCRIPT_DIR/email-count.sh")
slack_count=$("$SCRIPT_DIR/slack-count.sh")
messages_count=$("$SCRIPT_DIR/messages-count.sh")

# Build the output string
output=""

# Add email count if > 0
if [ "$email_count" -gt 0 ] 2>/dev/null; then
    output="📧 $email_count"
fi

# Add slack count if > 0
if [ "$slack_count" -gt 0 ] 2>/dev/null; then
    if [ -n "$output" ]; then
        output="$output  💬 $slack_count"
    else
        output="💬 $slack_count"
    fi
fi

# Add messages count if > 0
if [ "$messages_count" -gt 0 ] 2>/dev/null; then
    if [ -n "$output" ]; then
        output="$output  💚 $messages_count"
    else
        output="💚 $messages_count"
    fi
fi

# Output the result (empty string if no notifications)
echo "$output"