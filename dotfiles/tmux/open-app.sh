#!/usr/bin/env bash
# Open the appropriate app based on the argument

case "$1" in
    mail|email)
        open -a Mail
        ;;
    slack)
        open -a Slack
        ;;
    messages|imessage)
        open -a Messages
        ;;
    *)
        echo "Unknown app: $1"
        exit 1
        ;;
esac