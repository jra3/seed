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
    # Current time in Messages format: (seconds since 1970 - 978307200) * 1000000000
    # 90 days = 7776000 seconds
    CURRENT_EPOCH=$(date +%s)
    SECONDS_SINCE_2001=$(( CURRENT_EPOCH - 978307200 ))
    NINETY_DAYS_AGO_SECONDS=$(( SECONDS_SINCE_2001 - 7776000 ))
    NINETY_DAYS_AGO=$(( NINETY_DAYS_AGO_SECONDS * 1000000000 ))
    
    # Count unread messages from the last 90 days that are associated with a chat
    # Only count messages that appear in Messages.app (have a chat_id)
    # Exclude filtered (junk) messages and messages older than last_read_message_timestamp
    count=$(sqlite3 -line "$CHAT_DB" "
        SELECT COUNT(*) 
        FROM message m
        INNER JOIN chat_message_join cmj ON m.ROWID = cmj.message_id
        INNER JOIN chat c ON cmj.chat_id = c.ROWID
        WHERE m.is_read = 0 
        AND m.is_from_me = 0 
        AND m.error = 0
        AND m.date > $NINETY_DAYS_AGO
        AND c.is_filtered = 0
        AND (c.last_read_message_timestamp = 0 OR m.date > c.last_read_message_timestamp);" 2>/dev/null | grep -o '[0-9]\+' | head -1)
    
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