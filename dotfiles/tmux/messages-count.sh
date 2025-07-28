#!/usr/bin/env bash
# Get unread message count from Messages.app

# Method 1: Try lsappinfo (though it often returns NULL for Messages)
count=$(lsappinfo -all info -only StatusLabel Messages 2>/dev/null | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
if [ -n "$count" ] && [ "$count" != "NULL" ] && [ "$count" -gt 0 ] 2>/dev/null; then
    echo "$count"
    exit 0
fi

# Method 2: Query chat.db directly with better query
CHAT_DB="$HOME/Library/Messages/chat.db"
if [ -f "$CHAT_DB" ]; then
    # Count unread messages that are not from me and have text content
    count=$(sqlite3 "$CHAT_DB" "
        SELECT COUNT(guid) 
        FROM message 
        WHERE NOT(is_read) 
        AND NOT(is_from_me) 
        AND text != '';" 2>/dev/null)
    
    if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
        echo "$count"
        exit 0
    fi
fi

# Method 3: Alternative chat.db query using numeric values
if [ -f "$CHAT_DB" ]; then
    # Some versions use 0/1 instead of boolean
    count=$(sqlite3 "$CHAT_DB" "
        SELECT COUNT(*) 
        FROM message 
        WHERE is_read = 0 
        AND is_from_me = 0 
        AND text IS NOT NULL 
        AND text != '';" 2>/dev/null)
    
    if [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
        echo "$count"
        exit 0
    fi
fi

# Default to 0 if no method works
echo "0"