#!/usr/bin/env bash
# Get unread message count from Messages.app

# Method 1: Try lsappinfo (though it often returns NULL for Messages)
count=$(lsappinfo -all info -only StatusLabel Messages 2>/dev/null | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
if [ -n "$count" ] && [ "$count" != "NULL" ] && [ "$count" -gt 0 ] 2>/dev/null; then
    echo "$count"
    exit 0
fi

# Method 2: Query chat.db for recent unread messages
# Only count real messages that would show in Messages.app unread section
CHAT_DB="$HOME/Library/Messages/chat.db"
if [ -f "$CHAT_DB" ]; then
    # Messages.app uses nanoseconds since 2001-01-01 for dates
    # We need to calculate the date 90 days ago in this format
    # macOS date reference: seconds between 2001-01-01 and 1970-01-01 is 978307200
    
    # Get current time in seconds since 1970, subtract 90 days (7776000 seconds), then convert to Messages format
    NINETY_DAYS_AGO=$(( ($(date +%s) - 978307200 - 7776000) * 1000000000 ))
    
    # Count only REAL unread messages (not reactions, system messages, etc.)
    # item_type = 0: regular messages
    # item_type = 1: member changes
    # item_type = 2: name changes  
    # item_type = 3: group messages with attachments
    # item_type = 4: location sharing
    # item_type = 5: other system messages
    # We only want type 0 with actual text content
    count=$(sqlite3 -line "$CHAT_DB" "
        SELECT COUNT(*) 
        FROM message 
        WHERE is_read = 0 
        AND is_from_me = 0 
        AND item_type = 0
        AND text IS NOT NULL 
        AND text != ''
        AND error = 0
        AND date > $NINETY_DAYS_AGO;" 2>/dev/null | grep -o '[0-9]\+' | head -1)
    
    if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
        echo "$count"
        exit 0
    fi
fi

# Method 3: Try AppleScript to get unread count (requires Messages to be running)
# This won't work if Messages isn't open, but it's worth trying
count=$(osascript -e 'tell application "Messages"
    set unreadCount to 0
    repeat with theChat in chats
        set unreadCount to unreadCount + (count of (messages of theChat whose read is false and sender is not me))
    end repeat
    return unreadCount
end tell' 2>/dev/null)

if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
    echo "$count"
    exit 0
fi

# Method 4: Alternative query - just count ALL unread not from me
# Use this as fallback if you want to see all unread messages regardless of age
# Uncomment the following if you want to count ALL unread messages:
# if [ -f "$CHAT_DB" ]; then
#     count=$(sqlite3 "$CHAT_DB" "
#         SELECT COUNT(*) 
#         FROM message 
#         WHERE is_read = 0 
#         AND is_from_me = 0;" 2>/dev/null | tr -d '[:space:]')
#     
#     if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
#         echo "$count"
#         exit 0
#     fi
# fi

# Default to 0 if no method works
echo "0"