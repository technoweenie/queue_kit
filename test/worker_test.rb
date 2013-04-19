require File.expand_path("../helper", __FILE__)

class WorkerTest < Test::Unit::TestCase
  def test_cooler
    cooled = false
    worker = nil
    cooler = lambda { worker.stop;cooled = true }

    worker = new_worker [], :processor => lambda { |_| fail 'item found?' },
      :cooler => cooler

    worker.run
    assert cooled
  end

  def test_custom_on_error_handler
    called = false
    error_handler = lambda do |exc|
      called = true
      assert_equal 'booya', exc.message
    end

    worker = new_worker [1], :processor => lambda { |_| raise 'booya' },
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

  def test_new_worker_is_not_working
    assert !new_worker.working?
  end

  def new_worker(queue = [], options = {})
    options[:instrumenter] ||= NullInstrumenter.new
    Worker.new(queue, options)
  end

  class Worker
    include QueueKit::Worker
  end
end

