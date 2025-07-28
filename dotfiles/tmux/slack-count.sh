#!/usr/bin/env bash
# Get Slack notification count

# Method 1: Use lsappinfo (works well for Slack)
count=$(lsappinfo -all info -only StatusLabel Slack 2>/dev/null | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
if [ -n "$count" ] && [ "$count" != "NULL" ] && [ "$count" -gt 0 ] 2>/dev/null; then
    echo "$count"
    exit 0
fi

# Method 2: Query notification center database (fallback)
NC_DB=$(find ~/Library/Application\ Support/NotificationCenter -name "*.db" 2>/dev/null | head -1)

if [ -n "$NC_DB" ]; then
    # Try different identifiers for Slack
    for identifier in "com.tinyspeck.slackmacgap" "Slack"; do
        count=$(sqlite3 "$NC_DB" "
            SELECT badge 
            FROM record 
            WHERE (app_id = '$identifier' OR bundle_id = '$identifier')
            AND badge > 0
            ORDER BY delivered_date DESC 
            LIMIT 1;" 2>/dev/null)
        
        if [ -n "$count" ] && [ "$count" != "NULL" ] && [ "$count" -gt 0 ] 2>/dev/null; then
            echo "$count"
            exit 0
        fi
    done
fi

# Default to 0 if no method works
echo "0"