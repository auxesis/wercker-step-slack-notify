[![wercker status](https://app.wercker.com/status/6077bdbf04300a6412268672fa39e71b/m "wercker status")](https://app.wercker.com/project/bykey/6077bdbf04300a6412268672fa39e71b)

# slack-notify-via-webhook

Send a message to a [Slack](https://slack.com/) Channel.

This integration is written in pure shell, and should run on every wercker box.

It uses the updated Slack WebHooks that use a private URL,
(e.g. `https://hooks.slack.com/services/R123YR45B/B678ZTJAY/AERfldaT9X`)

## Setup

For this integration to work, you must create a webhook integration on Slack:

1. Go to the account page on your Slack domain e.g. `<your-subdomain>.slack.com/services`.
1. Add an 'Incoming WebHooks' integration.
1. Select a default channel.
1. Copy the Webhook URL.

Now add a variable in your Wercker application:

1. Go to the settings tab of your application.
1. Go to the pipeline section.
1. Add a text variable named `SLACK_WEBHOOK_URL`
1. Set the value of the variable to the Webhook URL you copied from Slack

Finally, you need to add after steps to your `wercker.yml`:

``` yaml
build:
    after-steps:
        - auxesis/slack-notify:
            webhook_url: $SLACK_WEBHOOK_URL
            channel: "#general"
```

## Parameters

### Required

* `webhook_url` - The Webhook URL you have configured in Slack.
* `channel` - The channel name of the Slack Channel (with the `#`).

### Optional

* `username` - The bot username in Slack.
* `icon_url` - The icon to use for this bot's avatar in Slack.
* `icon_emoji` - The emoji to use use for this bot's avatar is Slack.
* `passed_message` - The message which will be shown on a passed build or deploy.
* `failed_message` - The message which will be shown on a failed build or deploy.

# License

The MIT License (MIT)

Copyright (c) 2015 Lindsay Holmwood

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Changelog

## 0.1.0
- Make construction of JSON a little more elegant and flexible.
- Add a bucketload of comments to explain wtf is going on.
- Add basic debugging output for local testing, triggered by setting `WERCKER_SLACK_NOTIFY_DEBUG`.
- Make README easier to follow. Update instructions for latest Slack.

## 0.0.11
- added custom passed/failed message
- change how to specify the channel(Ex. "#room", "@someone")
- change default icon and username

## 0.0.8
- added custom icon url, icon emoji, and username properties

## 0.0.6
- Deploy url added
- the build/deploy words are now used as links instead of showing the full
url
- Show the branch name in the deploy message

## 0.0.5
- Minor change in documentation

## 0.0.4
- updated documentation
- check for redundant hash in channel argument
- tests added
