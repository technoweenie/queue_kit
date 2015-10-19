module QueueKit
  module Worker
    include Instrumentable

    def initialize(queue, options = {})
      @queue = queue
      @processor = options.fetch(:processor) { method(:process) }
      @cooler = options.fetch(:cooler) { method(:cool) }
      @error_handler = options.fetch(:error_handler) { method(:handle_error) }
      @stopped = true

      instrumenter_from(options)
    end

    def process(item)
      raise NotImplementedError, "This worker can't do anything with #{item.inspect}"
    end

    def cool
    end

    def handle_error(err)
      raise err
    end

    def trap_signals(signal_handler)
      SignalChecker.trap(self, signal_handler)
    end

    def run
      start
      interval_debugger = lambda { "worker.interval" }

      loop do
        work
        break unless working?
        debug(&interval_debugger)
      end
    end

    def procline(string)
      $0 = "QueueKit-#{QueueKit::VERSION}: #{string}"
      debug { ["worker.procline", {:message => string}] }
    end

    def work
      wrap_error { work! }
    end

    def work!
      if item = @queue.pop
        set_working_procline
        @processor.call(item)
        set_popping_procline
      else
        @cooler.call if working?
      end
    end

    def wrap_error
      yield
    rescue Exception => exception
      @error_handler.call(exception)
    end

    def name
      @name ||= "#{self.class} #{Socket.gethostname}:#{Process.pid}"
    end

    def start
      set_popping_procline
      @stopped = false
    end

    def stop
      @stopped = true
    end

    def working?
      !@stopped
    end

    def set_working_procline
      procline("Processing since #{Time.now.to_i}")
    end

    def set_popping_procline
      @last_job_at = Time.now
      procline("Waiting since #{@last_job_at.to_i}")
    end

    def default_instrument_options
      {:worker => self}
    end
  end
end

