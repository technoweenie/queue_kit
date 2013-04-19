require File.expand_path("../helper", __FILE__)
QueueKit.require_lib 'clients/command_timeout'

class CommandTimeoutTest < Test::Unit::TestCase
  include QueueKit::Clients::CommandTimeout

  def test_with_ivars
    object = FakeQueue.new
    assert_equal 10, object.command_timeout_ms
    assert_equal 1000, object.max_command_timeout_ms

    object.command_timeout_from({})
    assert_equal 10, object.command_timeout_ms
    assert_equal 1000, object.max_command_timeout_ms

    object.command_timeout_from \
      :command_timeout_ms => 1, :max_command_timeout_ms => 2
    assert_equal 1, object.command_timeout_ms
    assert_equal 2, object.max_command_timeout_ms
  end

  def test_gets_timeout_for_first_attempt
    assert_equal 10, command_timeout(attempts=0)
  end

  def test_backs_off
    assert_equal 20, command_timeout(attempts=1)
    assert_equal 30, command_timeout(attempts=2)
  end

  def test_enforces_max_timeout
    assert_equal 1000, command_timeout(attempts=1000)
  end

  class FakeQueue
    include QueueKit::Clients::CommandTimeout
  end
end

