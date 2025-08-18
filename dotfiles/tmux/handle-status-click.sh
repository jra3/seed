#!/usr/bin/env bash
# Handle mouse clicks on tmux status bar
# Called with status-right content and mouse x position

STATUS_RIGHT="$1"
MOUSE_X="$2"

# Get the actual notification string from the status bar
NOTIFICATIONS=$(/Users/john/.config/tmux/notifications.sh)

# Debug logging (can be removed later)
echo "Mouse X: $MOUSE_X, Notifications: '$NOTIFICATIONS'" >> /tmp/tmux-click.log

# Parse the notifications to find positions
# Each emoji+number takes roughly 4-6 characters of width
# We'll estimate positions based on the notification string

# Count what's visible and estimate positions
email_pos=-1
slack_pos=-1
messages_pos=-1
current_pos=0

if [[ "$NOTIFICATIONS" == *"📧"* ]]; then
    email_pos=$current_pos
    # Move position forward by emoji + space + number + spaces
    # Rough estimate: 5-7 characters width
    current_pos=$((current_pos + 7))
fi

if [[ "$NOTIFICATIONS" == *"💬"* ]]; then
    slack_pos=$current_pos
    current_pos=$((current_pos + 7))
fi

if [[ "$NOTIFICATIONS" == *"💚"* ]]; then
    messages_pos=$current_pos
    current_pos=$((current_pos + 7))
fi

# For now, let's use a simpler approach:
# If only one notification type is visible, open that app
# If multiple are visible, we'll need to estimate based on position

# Count how many notification types are visible
num_notifications=0
[[ "$NOTIFICATIONS" == *"📧"* ]] && ((num_notifications++))
[[ "$NOTIFICATIONS" == *"💬"* ]] && ((num_notifications++))
[[ "$NOTIFICATIONS" == *"💚"* ]] && ((num_notifications++))

if [ $num_notifications -eq 1 ]; then
    # Only one type visible, open that one
    if [[ "$NOTIFICATIONS" == *"📧"* ]]; then
        open -a Mail
        echo "Opening Mail (only notification)" >> /tmp/tmux-click.log
    elif [[ "$NOTIFICATIONS" == *"💬"* ]]; then
        open -a Slack
        echo "Opening Slack (only notification)" >> /tmp/tmux-click.log
    elif [[ "$NOTIFICATIONS" == *"💚"* ]]; then
        open -a Messages
        echo "Opening Messages (only notification)" >> /tmp/tmux-click.log
    fi
else
    # Multiple notifications visible - use position to determine
    # This is a rough approximation since we don't know exact character widths
    # First notification is typically around position 170-180
    # Each additional notification adds about 7-10 positions
    
    # Get the terminal width to help with calculations
    TERM_WIDTH=$(tmux display -p '#{window_width}')
    
    # Rough position calculations (may need adjustment)
    # Assuming notifications start around position TERM_WIDTH - 30
    notif_start=$((TERM_WIDTH - 35))
    
    if [[ $MOUSE_X -lt $((notif_start + 8)) ]] && [[ "$NOTIFICATIONS" == *"📧"* ]]; then
        open -a Mail
        echo "Opening Mail (position-based)" >> /tmp/tmux-click.log
    elif [[ $MOUSE_X -lt $((notif_start + 16)) ]] && [[ "$NOTIFICATIONS" == *"💬"* ]]; then
        open -a Slack
        echo "Opening Slack (position-based)" >> /tmp/tmux-click.log
    elif [[ "$NOTIFICATIONS" == *"💚"* ]]; then
        open -a Messages
        echo "Opening Messages (position-based)" >> /tmp/tmux-click.log
    else
        # Default to first visible notification
        if [[ "$NOTIFICATIONS" == *"📧"* ]]; then
            open -a Mail
            echo "Opening Mail (default)" >> /tmp/tmux-click.log
        elif [[ "$NOTIFICATIONS" == *"💬"* ]]; then
            open -a Slack
            echo "Opening Slack (default)" >> /tmp/tmux-click.log
        elif [[ "$NOTIFICATIONS" == *"💚"* ]]; then
            open -a Messages
            echo "Opening Messages (default)" >> /tmp/tmux-click.log
        fi
    fi
fi