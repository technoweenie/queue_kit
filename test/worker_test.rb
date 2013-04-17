require File.expand_path("../helper", __FILE__)

class WorkerTest < Test::Unit::TestCase
  def test_custom_on_error
    worker = QueueKit::Worker.new :queue => [1]
    worker.on_pop do |job|
      raise 'booya'
    end

    called = false
    worker.on_error do |job, exc|
      called = true
      assert_equal 1, job.item
      assert_equal 'booya', exc.message
    end

    worker.work

    assert called
  end

  def test_default_on_error
    worker = QueueKit::Worker.new :queue => [1]
    worker.on_pop do |job|
      raise job.item.to_s
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
    worker = QueueKit::Worker.new :queue => [nil, 1]

    worker.on_pop do |job|
      fail "callback called multiple times" if called
      assert_equal 1, job.item
      called = true
      worker.stop
    end

    worker.run

    assert called
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

