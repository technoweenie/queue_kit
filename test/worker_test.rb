require File.expand_path("../helper", __FILE__)

class WorkerTest < Test::Unit::TestCase
  def test_after_work
    items = []
    queue = [1,2,3,4,5]
    processor = lambda { |item| items << item }
    calls = 0

    worker = new_worker queue, :processor => processor

    worker.after_work do
      calls += 1
      worker.stop if items.size > 2
    end

    worker.run

    assert_equal 3, calls
    assert_equal [5, 4, 3], items
    assert_equal [1, 2], queue
  end

  def test_custom_on_error_handler
    called = false
    error_handler = lambda do |exc|
      called = true
      assert_equal 'booya', exc.message
    end

    worker = new_worker [1], :processor => lambda { |item| raise 'booya' },
      :error_handler => error_handler

    worker.work

    assert called
  end

  def test_default_error_handler
    processor = lambda do |item|
      raise item.to_s
    end

    worker = new_worker [1], :processor => processor

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
    worker = nil

    processor = lambda do |item|
      fail "callback called multiple times" if called
      assert_equal 1, item
      called = true
      worker.stop
    end

    worker = new_worker [1, nil], :processor => processor
    worker.run

    assert called
  end

  def test_needs_processor_callback_to_work
    worker = new_worker
    assert_raises RuntimeError do
      worker.start
    end

    worker = new_worker [], :processor => lambda { puts 'hi' }
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

