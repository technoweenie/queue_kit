require File.expand_path("../helper", __FILE__)

class WorkerTest < Test::Unit::TestCase
  def test_after_work
    items = []
    queue = [1,2,3,4,5]
    calls = 0
    worker = new_worker queue

    worker.on_pop do |item|
      items << item
    end

    worker.after_work do
      calls += 1
      worker.stop if items.size > 2
    end

    worker.run

    assert_equal 3, calls
    assert_equal [5, 4, 3], items
    assert_equal [1, 2], queue
  end

  def test_custom_on_error
    worker = new_worker [1]
    worker.on_pop do |item|
      raise 'booya'
    end

    called = false
    worker.on_error do |exc|
      called = true
      assert_equal 'booya', exc.message
    end

    worker.work

    assert called
  end

  def test_default_on_error
    worker = new_worker [1]
    worker.on_pop do |item|
      raise item.to_s
    end

    begin
      worker.work
    rescue RuntimeError => err
      assert_equal '1', err.message
    else
      fail "no exception raised"
    end
  end

  def test_breaks_when_stopped
    called = false
    worker = new_worker [1, nil]

    worker.on_pop do |item|
      fail "callback called multiple times" if called
      assert_equal 1, item
      called = true
      worker.stop
    end

    worker.run

    assert called
  end

  def test_needs_on_pop_callback_to_work
    worker = new_worker
    assert_raises RuntimeError do
      worker.start
    end

    worker.on_pop { puts 'hi' }
    assert !worker.working?
    worker.start
    assert worker.working?
  end

  def test_new_worker_is_not_working
    assert !new_worker.working?
  end

  def new_worker(queue = [], options = {})
    options[:instrumenter] ||= NullInstrumenter.new
    QueueKit::Worker.new(queue, options)
  end

  class NullInstrumenter
    def instrument(name, payload = nil)
    end
  end
end

