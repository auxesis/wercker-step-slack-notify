#!/bin/bash

# Argument checking
if [ -z "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL" ]; then
  fail "Please specify WEBHOOK_URL"
  exit 1
fi

# Payload generation
payload="payload={"

# Channel
if [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_CHANNEL" ]; then
  payload="$payload \"channel\":\"$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_CHANNEL\","
else
  payload="$payload \"channel\": \"#general\","
fi

# Username
if [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_USERNAME" ]; then
  payload="$payload \"username\":\"$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_USERNAME\","
else
  payload="$payload \"username\": \"Wercker\","
fi

# Icon
if [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_URL" ]; then
  payload="$payload \"icon_url\":\"$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_URL\","
elif [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_EMOJI" ]; then
  payload="$payload \"icon_emoji\":\"$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_EMOJI\","
else
  payload="$payload \"icon_url\": \"https://avatars3.githubusercontent.com/u/1695193?s=140\","
fi

# Message

# Build up all the possible messages we can send to Slack
if [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE" ]; then
  export BUILD_PASSED_MESSAGE=$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE
  export DEPLOY_PASSED_MESSAGE=$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE
else
  export BUILD_PASSED_MESSAGE=":white_check_mark: $WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: <$WERCKER_BUILD_URL|build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY passed."
  export DEPLOY_PASSED_MESSAGE=":white_check_mark: $WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: <$WERCKER_DEPLOY_URL|deploy> of $WERCKER_GIT_BRANCH to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY passed."
fi

if [ -n "$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE" ]; then
  export BUILD_FAILED_MESSAGE=$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE
  export DEPLOY_FAILED_MESSAGE=$WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE
else
  export BUILD_FAILED_MESSAGE=":no_entry: $WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: <$WERCKER_BUILD_URL|build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY failed."
  export DEPLOY_FAILED_MESSAGE=":no_entry: $WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME: <$WERCKER_DEPLOY_URL|deploy> of $WERCKER_GIT_BRANCH to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY failed."
fi

# Determine the message we need
case "$DEPLOY" in
true)  TYPE=DEPLOY ;;
*)     TYPE=BUILD ;;
esac

RESULT=$(echo $WERCKER_RESULT | tr a-z A-Z)
message_type="${TYPE}_${RESULT}_MESSAGE"
message="$(echo ${!message_type})"

# Add the message to the payload
payload="$payload \"text\":\"$message\""
payload="$payload }" # Close the JSON document

# Make the request
debug $payload

RESPONSE_OUTPUT="$WERCKER_STEP_TEMP/body.log"
RESPONSE_CODE=$(curl -s -X POST --data-urlencode "$payload" $WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL --output $RESPONSE_OUTPUT -w "%{http_code}")
RETVAL=$?

if [ "$RESPONSE_CODE" = "000" ]; then
  fail "Couldn't connect to $WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL"
fi

if [ "$RESPONSE_CODE" = "500" ]; then
  fail "$(cat $RESPONSE_OUTPUT)"
fi

if [ "$RESPONSE_CODE" = "404" ]; then
  fail "Webhook doesn't exist"
fi

debug "HTTP status: $RESPONSE_CODE"
debug "HTTP response body:"
debug $(cat $RESPONSE_OUTPUT)
