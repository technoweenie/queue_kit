module QueueKit
  class Worker
    def initialize(options = {})
      @queue = options.fetch(:queue) { [] }
      @on_pop = options.fetch(:on_pop) {}
      @on_error = options.fetch(:on_error) { lambda { |e| raise e } }
      @after_work = options.fetch(:after_work) { lambda {} }
      @instrumenter = options.fetch(:instrumenter) { PutsInstrumenter.new }
      @stopped = true

      if options.fetch(:debug) { false }
        class << self
          alias debug force_debug
        end
      end
    end

    def run
      start
      interval_debugger = lambda { "worker.interval" }

      loop do
        working? ? work : break
        debug(&interval_debugger)
        @after_work.call
      end
    end

    def procline(string)
      $0 = "QueueKit-#{QueueKit::Version}: #{string}"
      debug { ["worker.procline", {:message => string}] }
    end

    def on_pop(&block)
      @on_pop = block
    end

    def on_error(&block)
      @on_error = block
    end

    def after_work(&block)
      @after_work = block
    end

    def work
      handle_error do
        item = @queue.pop
        @on_pop.call(item) if item
      end
    end

    def handle_error
      yield
    rescue Exception => exception
      @on_error.call(exception)
    end

    def start
      if !@on_pop
        raise "Needs something to do with an item.  Set #on_pop"
      end

      instrument "worker.start"
      @stopped = false
    end

    def stop
      instrument "worker.stop"
      @stopped = true
    end

    def working?
      !@stopped
    end

    def instrument(name, payload = nil)
      (payload ||= {}).update(:worker => self)
      @instrumenter.instrument("queuekit.#{name}", payload)
    end

    def force_debug
      instrument(*yield)
    end

    def debug
    end

    class PutsInstrumenter
      def instrument(name, payload = nil)
        puts "[#{Time.now}] #{name}: #{payload.inspect}"
      end
    end
  end
end

