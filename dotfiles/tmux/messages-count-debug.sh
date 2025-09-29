#!/usr/bin/env bash
# Debug script to test various methods for getting Messages notification count

echo "=== Method 1: lsappinfo ==="
lsappinfo -all info -only StatusLabel Messages 2>/dev/null | head -5

echo -e "\n=== Method 2: Check Notification Center database ==="
NC_DB=$(find ~/Library/Application\ Support/NotificationCenter -name "*.db" 2>/dev/null | head -1)
if [ -n "$NC_DB" ]; then
    echo "Found NC database: $NC_DB"
    sqlite3 "$NC_DB" "SELECT app_id, bundle_id, badge FROM record WHERE (app_id LIKE '%message%' OR bundle_id LIKE '%message%') AND badge > 0;" 2>/dev/null
else
    echo "No Notification Center database found"
fi

echo -e "\n=== Method 3: AppleScript approach ==="
osascript -e 'tell application "System Events" to tell process "Messages" to get value of attribute "AXStatusLabel" of window 1' 2>/dev/null || echo "AppleScript method failed"

echo -e "\n=== Method 4: Check dock badge ==="
osascript -e 'tell application "System Events" to tell process "Dock" to get badge text of UI element "Messages"' 2>/dev/null || echo "Dock badge method failed"

echo -e "\n=== Method 5: Direct AppleScript to Messages ==="
osascript -e 'tell application "Messages" to get unread count of every chat' 2>/dev/null || echo "Direct Messages AppleScript failed"

echo -e "\n=== Method 6: Check recent messages in chat.db ==="
CHAT_DB="$HOME/Library/Messages/chat.db"
if [ -f "$CHAT_DB" ]; then
    echo "Recent unread messages (last 7 days):"
    sqlite3 "$CHAT_DB" "
        SELECT COUNT(*) as unread_count
        FROM message 
        WHERE is_read = 0 
        AND is_from_me = 0 
        AND date > (strftime('%s', 'now', '-7 days') * 1000000000);" 2>/dev/null
    
    echo "Total unread messages in database:"
    sqlite3 "$CHAT_DB" "SELECT COUNT(*) FROM message WHERE is_read = 0 AND is_from_me = 0;" 2>/dev/null
fi

echo -e "\n=== Method 7: Check with different app identifiers ==="
for identifier in "com.apple.MobileSMS" "com.apple.iChat" "com.apple.Messages" "Messages"; do
    echo "Trying identifier: $identifier"
    lsappinfo -all info -only StatusLabel "$identifier" 2>/dev/null | grep -v NULL
done

echo -e "\n=== Method 8: Use defaults to check notification settings ==="
defaults read com.apple.ncprefs apps 2>/dev/null | grep -A 5 -i messages || echo "No Messages notification settings found"