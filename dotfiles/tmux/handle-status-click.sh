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
    # Multiple notifications visible - parse the string to determine positions
    # Each notification is in format "📧 N" or "💬 N" with spaces between
    
    # Get the terminal width for reference
    TERM_WIDTH=$(tmux display -p '#{window_width}')
    
    echo "Multiple notifications, parsing: '$NOTIFICATIONS' at X=$MOUSE_X (width=$TERM_WIDTH)" >> /tmp/tmux-click.log
    
    # Parse the notification string to find what's at each position
    # The notifications appear at the right side of the status bar
    # We need to calculate where each icon starts
    
    # Count the visible notifications and their order
    first_icon=""
    second_icon=""
    third_icon=""
    
    # Parse the string to identify order of icons
    if [[ "$NOTIFICATIONS" =~ (📧|💬|💚) ]]; then
        # Extract icons in order using sed
        icons=($(echo "$NOTIFICATIONS" | grep -o '[📧💬💚]'))
        
        echo "Found ${#icons[@]} icons: ${icons[*]}" >> /tmp/tmux-click.log
        
        # Estimate positions based on notification string length
        # The entire notification string starts roughly at position TERM_WIDTH - string_length - time_length
        # Time is roughly 6 chars (" HH:MM")
        notif_length=${#NOTIFICATIONS}
        notif_start=$((TERM_WIDTH - notif_length - 10))  # -10 for time and padding
        
        echo "Notification starts at approx position $notif_start" >> /tmp/tmux-click.log
        
        # Calculate rough boundaries for each icon
        # Each "📧 N" takes about 4-5 characters of width
        # Plus 2 spaces between notifications
        
        if [ ${#icons[@]} -eq 1 ]; then
            # Only one icon, always open its app
            case ${icons[0]} in
                📧) open -a Mail; echo "Opening Mail (single)" >> /tmp/tmux-click.log ;;
                💬) open -a Slack; echo "Opening Slack (single)" >> /tmp/tmux-click.log ;;
                💚) open -a Messages; echo "Opening Messages (single)" >> /tmp/tmux-click.log ;;
            esac
        elif [ ${#icons[@]} -eq 2 ]; then
            # Two icons - split the space
            # First icon roughly from notif_start to notif_start + notif_length/2
            # Second icon from notif_start + notif_length/2 to end
            mid_point=$((notif_start + notif_length / 2))
            
            echo "Two icons, midpoint at $mid_point" >> /tmp/tmux-click.log
            
            if [[ $MOUSE_X -lt $mid_point ]]; then
                # Clicked on first icon
                case ${icons[0]} in
                    📧) open -a Mail; echo "Opening Mail (first of two)" >> /tmp/tmux-click.log ;;
                    💬) open -a Slack; echo "Opening Slack (first of two)" >> /tmp/tmux-click.log ;;
                    💚) open -a Messages; echo "Opening Messages (first of two)" >> /tmp/tmux-click.log ;;
                esac
            else
                # Clicked on second icon
                case ${icons[1]} in
                    📧) open -a Mail; echo "Opening Mail (second of two)" >> /tmp/tmux-click.log ;;
                    💬) open -a Slack; echo "Opening Slack (second of two)" >> /tmp/tmux-click.log ;;
                    💚) open -a Messages; echo "Opening Messages (second of two)" >> /tmp/tmux-click.log ;;
                esac
            fi
        else
            # Three icons - divide into thirds
            first_boundary=$((notif_start + notif_length / 3))
            second_boundary=$((notif_start + 2 * notif_length / 3))
            
            echo "Three icons, boundaries at $first_boundary and $second_boundary" >> /tmp/tmux-click.log
            
            if [[ $MOUSE_X -lt $first_boundary ]]; then
                # First icon
                case ${icons[0]} in
                    📧) open -a Mail; echo "Opening Mail (first of three)" >> /tmp/tmux-click.log ;;
                    💬) open -a Slack; echo "Opening Slack (first of three)" >> /tmp/tmux-click.log ;;
                    💚) open -a Messages; echo "Opening Messages (first of three)" >> /tmp/tmux-click.log ;;
                esac
            elif [[ $MOUSE_X -lt $second_boundary ]]; then
                # Second icon
                case ${icons[1]} in
                    📧) open -a Mail; echo "Opening Mail (second of three)" >> /tmp/tmux-click.log ;;
                    💬) open -a Slack; echo "Opening Slack (second of three)" >> /tmp/tmux-click.log ;;
                    💚) open -a Messages; echo "Opening Messages (second of three)" >> /tmp/tmux-click.log ;;
                esac
            else
                # Third icon
                case ${icons[2]} in
                    📧) open -a Mail; echo "Opening Mail (third of three)" >> /tmp/tmux-click.log ;;
                    💬) open -a Slack; echo "Opening Slack (third of three)" >> /tmp/tmux-click.log ;;
                    💚) open -a Messages; echo "Opening Messages (third of three)" >> /tmp/tmux-click.log ;;
                esac
            fi
        fi
    fi
fi