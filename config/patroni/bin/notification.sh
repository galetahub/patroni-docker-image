#!/bin/bash

API_TOKEN=$TELEGRAM_API_TOKEN
CHAT_ID=$TELEGRAM_CHAT_ID
AUTHOR_NAME=$(hostname -i)
URL="https://api.telegram.org/bot$API_TOKEN/sendMessage"

# Set the message text
MESSAGE="🚀<b>$1</b> callback triggered by $AUTHOR_NAME on $HOSTNAME ($2/$3)"

# Use the curl command to send the message
curl -s -X POST $URL -d chat_id=$CHAT_ID -d parse_mode=HTML -d text="${MESSAGE}"
