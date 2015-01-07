describe 'slack-notify-via-webhook' do
  # Common environment variables used all notification types.
  let(:defaults) { {
    "WERCKER_APPLICATION_OWNER_NAME" => "adalovelace",
    "WERCKER_APPLICATION_NAME"       => "analytical_engine",
    "WERCKER_GIT_BRANCH"             => "master",
    "WERCKER_STARTED_BY"             => "Ada Lovelace",
    "WERCKER_DEPLOYTARGET_NAME"      => "production",
  } }

  # Build environment variables
  let(:build) { {
    "WERCKER_BUILD_URL" => "https://app.wercker.com/#build/decafc0ffee",
    "DEPLOY"            => false,
  } }

  # Deploy environment variables
  let(:deploy) { {
    "WERCKER_DEPLOY_URL"        => "https://app.wercker.com/#deploy/c0ffeefacade",
    "WERCKER_DEPLOYTARGET_NAME" => "production",
    "DEPLOY"                    => true,
  } }

  it 'validates webhook url is set' do
    runner(defaults, fail_on_error=false)

    assert_matching_output("fail: Please specify WEBHOOK_URL", all_output)
  end

  it 'notifies on webhook connect failure' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9900/hello',
      'WERCKER_RESULT' => 'success',
    })

    runner(environment, fail_on_error=false)

    assert_matching_output("fail: Couldn't connect to #{environment['WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL']}", all_output)
  end

  it 'notifies to #general by default' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_build',
      'WERCKER_RESULT' => 'passed',
    })
    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['channel']).to eq "#general"
  end

  it 'notifies on passed build with canned message' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_build',
      'WERCKER_RESULT' => 'passed',
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_OWNER_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_GIT_BRANCH"])
    expect(last_slack_request['text']).to include(environment["WERCKER_STARTED_BY"])
    expect(last_slack_request['text']).to include(environment["WERCKER_RESULT"])
    expect(last_slack_request['text']).to include("<" + environment["WERCKER_BUILD_URL"] + "|build>")
  end

  it 'notifies on failed build with canned message' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/failed_build',
      'WERCKER_RESULT' => 'failed',
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_OWNER_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_GIT_BRANCH"])
    expect(last_slack_request['text']).to include(environment["WERCKER_STARTED_BY"])
    expect(last_slack_request['text']).to include(environment["WERCKER_RESULT"])
    expect(last_slack_request['text']).to include("<" + environment["WERCKER_BUILD_URL"] + "|build>")
  end

  it 'notifies on passed deploy with canned message' do
    environment = defaults.merge(deploy).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_deploy',
      'WERCKER_RESULT' => 'passed',
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_OWNER_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_GIT_BRANCH"])
    expect(last_slack_request['text']).to include(environment["WERCKER_STARTED_BY"])
    expect(last_slack_request['text']).to include(environment["WERCKER_RESULT"])
    expect(last_slack_request['text']).to include("<" + environment["WERCKER_DEPLOY_URL"] + "|deploy>")
  end

  it 'notifies on failed deploy with canned message' do
    environment = defaults.merge(deploy).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/failed_build',
      'WERCKER_RESULT' => 'failed',
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_OWNER_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_APPLICATION_NAME"])
    expect(last_slack_request['text']).to include(environment["WERCKER_GIT_BRANCH"])
    expect(last_slack_request['text']).to include(environment["WERCKER_STARTED_BY"])
    expect(last_slack_request['text']).to include(environment["WERCKER_RESULT"])
    expect(last_slack_request['text']).to include("<" + environment["WERCKER_DEPLOY_URL"] + "|deploy>")
  end

  it 'supports custom passed messages' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE' => 'fuck yeah!'
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to eq environment["WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE"]
  end

  it 'supports custom failed messages' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/custom_failed',
      'WERCKER_RESULT' => 'failed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE' => 'fuck no!'
    })

    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['text']).to_not be nil
    expect(last_slack_request['text']).to eq environment["WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE"]
  end

  it 'supports a custom username' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_build',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_USERNAME' => 'foobarbaz'
    })
    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['username']).to eq "foobarbaz"
  end

  it 'supports a custom icon url' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_build',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_URL' => 'http://i.imgur.com/yIB7VAN.gif'
    })
    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['icon_url']).to eq environment['WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_URL']
  end

  it 'supports a custom emoji icon' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/passed_build',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_EMOJI' => ':ramen:'
    })
    runner(environment)

    expect(last_slack_request).to_not be nil
    expect(last_slack_request['icon_emoji']).to eq environment['WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_ICON_EMOJI']
  end

  it 'fails gracefully on slack failures' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/500',
    })

    runner(environment, fail_on_error=false)
    assert_matching_output("fail: a random error", all_output)
  end

  it "fails gracefully when webhook doesn't exist" do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_WEBHOOK_URL' => 'http://localhost:9988/404',
    })

    runner(environment, fail_on_error=false)
    assert_matching_output("fail: Webhook doesn't exist", all_output)
  end
end

# Wercker steps are executed on the Wercker platform by setting up an
# environment, then sourcing a user supplied script. When testing, this means
# you can't just execute `run.sh` - you need a parent script that sets up
# similar environment variables, then sources `run.sh`.
#
# The runner method does exactly that - it dynamically generates a shellscript
# from supplied environment variables, and executes the generated script.
def runner(environment, fail_on_error=true)
  # Generate the runner
  template = File.read("spec/support/runner.sh.erb")
  renderer = ERB.new(template, nil, '-')
  output   = renderer.result(binding)

  write_file('runner.sh', output)
  filesystem_permissions(0755, 'runner.sh')
  FileUtils.cp('run.sh', current_dir)

  # Execute the runner
  run_simple "#{current_dir}/runner.sh", fail_on_error
end

# During rspec initialisation we set up a web server that mocks out responses
# we would expect from Slack. When the web server receives a requet, it writes
# it into a global variable, for inspection by the tests.
#
# last_slack_request is a helper method to get the last request send to the mock
# Slack server.
def last_slack_request
  $SLACK_REQUEST_QUEUE.last
end
