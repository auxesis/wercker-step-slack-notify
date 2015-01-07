#!/bin/bash

# Mock out wercker's output functions, per http://devcenter.wercker.com/articles/steps/guide.html#toc_5
function success() {
  echo "success: $@"
}

function fail() {
  echo "fail: $@"
}

function warn() {
  echo "warn: $@"
}

function info() {
  echo "info: $@"
}

function debug() {
  echo "debug: $@"
}

export WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL='https://hooks.slack.com/services/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'
export WERCKER_SLACK_NOTIFY_VIA_CHANNEL="#log"
#export WERCKER_SLACK_NOTIFY_PASSED_MESSAGE="FUCK YEAH!"
#export WERCKER_SLACK_NOTIFY_FAILED_MESSAGE="FUCK NO!"
#export WERCKER_SLACK_NOTIFY_DEBUG="false"
#export WERCKER_SLACK_NOTIFY_ICON_EMOJI=":ghost:"
export WERCKER_STEP_TEMP=$(mktemp -d)

export WERCKER_RESULT="failed"
export DEPLOY="false"

export WERCKER_APPLICATION_OWNER_NAME="adalovelace"
export WERCKER_APPLICATION_NAME="analytical_engine"
export WERCKER_BUILD_URL="https://app.wercker.com/#build/decafc0ffee"
export WERCKER_DEPLOY_URL="https://app.wercker.com/#deploy/c0ffeefacade"
export WERCKER_GIT_BRANCH="master"
export WERCKER_STARTED_BY="Ada Lovelace"
export WERCKER_DEPLOYTARGET_NAME="production"

source ./run.sh
