require File.expand_path("../helper", __FILE__)
require File.expand_path("../../lib/queue_kit/clients/command_timeout", __FILE__)

class CommandTimeoutTest < Test::Unit::TestCase
  include QueueKit::Clients::CommandTimeout

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
end
