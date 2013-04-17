require File.expand_path("../helper", __FILE__)
QueueKit.require_lib 'clients/round_robin_shuffler'

class RoundRobinShufflerTest < Test::Unit::TestCase
  include QueueKit::Clients::RoundRobinShuffler

  attr_reader :clients

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
end

