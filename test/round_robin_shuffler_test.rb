require File.expand_path("../helper", __FILE__)
QueueKit.require_lib 'clients/round_robin_shuffler'

class RoundRobinShufflerTest < Test::Unit::TestCase
  include QueueKit::Clients::RoundRobinShuffler

  attr_reader :clients

  def test_client_command_with_retries
    clients = []

    set_clients 1, 2

    value = client_command_with_retries 3 do |client|
      clients << client
      nil
    end

    assert_equal [1, 2, 1], clients
    assert_nil value
  end

  def test_client_command_with_value
    clients = []

    set_clients 1, 2

    value = client_command_with_retries 3 do |client, attempts|
      assert_equal clients.size, attempts
      clients << client
      client == 2 ? :booya : nil
    end

    assert_equal [1, 2], clients
    assert_equal :booya, value
  end

  def test_with_ivars
    object = FakeQueue.new
    assert_equal 100, object.commands_per_client

    object.round_robin_from({})
    assert_equal 100, object.commands_per_client

    object.round_robin_from :commands_per_client => 1
    assert_equal 1, object.commands_per_client
  end

  def test_shuffles_solitary_client
    set_clients 1

    assert_equal 1, client
    assert_equal 1, client
    assert_equal 1, client
  end

  def test_shuffles_clients
    set_clients 1, 2

    assert_equal 1, client
    assert_equal 1, client
    assert_equal 2, client
  end

  def commands_per_client
    2
  end

  def set_clients(*clients)
    @client_index = @client_len = nil
    @clients = clients
    rotate_client
  end

  class FakeQueue
    include QueueKit::Clients::RoundRobinShuffler

    def default_instrumenter
      NullInstrumenter.new
    end
  end

  def default_instrumenter
    NullInstrumenter.new
  end
end

