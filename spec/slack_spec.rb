describe 'slack-notify-via-webhook' do
  let(:defaults) { {
    "WERCKER_APPLICATION_OWNER_NAME" => "adalovelace",
    "WERCKER_APPLICATION_NAME"       => "analytical_engine",
    "WERCKER_GIT_BRANCH"             => "master",
    "WERCKER_STARTED_BY"             => "Ada Lovelace",
    "WERCKER_DEPLOYTARGET_NAME"      => "production"
  } }

  let(:build) { {
    "WERCKER_BUILD_URL"              => "https://app.wercker.com/#build/decafc0ffee",
  } }

  let(:deploy) { {
    "WERCKER_DEPLOYTARGET_NAME"      => "production"
  } }

  it 'validates webhook url is set' do
    environment = defaults

    runner(defaults, fail_on_error=false)

    assert_matching_output("fail: Please specify WEBHOOK_URL", all_output)
  end

  it 'notifies on webhook connect failure' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9900/hello',
      'WERCKER_RESULT' => 'success',
      'DEPLOY'         => false
    })

    runner(environment, fail_on_error=false)

    assert_matching_output("fail: Couldn't connect to #{environment['WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL']}", all_output)
  end

  it 'notifies on build success' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE' => 'fuck yeah!'
    })

    runner(environment)
  end

  it 'notifies on build failure' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'failed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE' => 'fuck yeah!'
    })

    runner(environment)
  end

  it 'notifies on deploy success' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'passed',
      'DEPLOY'         => true
    })

    runner(environment)
  end

  it 'notifies on deploy failure' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'failed',
      'DEPLOY'         => true
    })

    runner(environment)
  end

  it 'supports custom passed messages' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_passed',
      'WERCKER_RESULT' => 'passed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_PASSED_MESSAGE' => 'fuck yeah!'
    })

    runner(environment)
  end

  it 'supports custom failed messages' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/custom_failed',
      'WERCKER_RESULT' => 'failed',
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_FAILED_MESSAGE' => 'fuck no!'
    })

    runner(environment)
  end

  it 'fails gracefully on slack failures' do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/500',
    })

    runner(environment, fail_on_error=false)
    assert_matching_output("fail: a random error", all_output)
  end

  it "fails gracefully when webhook doesn't exist" do
    environment = defaults.merge(build).merge({
      'WERCKER_SLACK_NOTIFY_VIA_WEBHOOK_URL' => 'http://localhost:9988/404',
    })

    runner(environment, fail_on_error=false)
    assert_matching_output("fail: Webhook doesn't exist", all_output)
  end
end

def runner(environment, fail_on_error=true)
  # Generate the runner
  template = File.read("spec/support/runner.sh.erb")
  renderer = ERB.new(template, nil, '-')
  output   = renderer.result(binding)

  write_file('runner.sh', output)
  filesystem_permissions(0755, 'runner.sh')
  FileUtils.cp('run.sh', current_dir)

  run_simple "#{current_dir}/runner.sh", fail_on_error
end
