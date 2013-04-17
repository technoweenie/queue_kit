require File.expand_path("../helper", __FILE__)

class WorkerTest < Test::Unit::TestCase
  def test_breaks_when_stopped
    called = false
    worker = QueueKit::Worker.new :queue => [nil, 1]

    worker.on_pop do |item|
      fail "callback called multiple times" if called
      assert_equal 1, item
      called = true
      worker.stop
    end

    worker.start
  end

  def test_needs_on_pop_callback_to_work
    worker = QueueKit::Worker.new
    assert_raises RuntimeError do
      worker.start
    end

    worker.on_pop { puts 'hi' }
    assert !worker.working?
    worker.start
    assert worker.working?
  end

  def test_new_worker_is_not_working
    assert !QueueKit::Worker.new.working?
  end
end

