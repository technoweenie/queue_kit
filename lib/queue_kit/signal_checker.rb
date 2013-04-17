module QueueKit
  class SignalChecker
    COMMON_SIGNALS = %w(TERM INT)
    JRUBY_SIGNALS = %w(QUIT USR1)
    OPTIONAL_SIGNALS = %w(USR2 CONT HUP)

    attr_reader :worker
    attr_reader :handler

    def self.trap(worker, handler)
      new(worker, handler).trap_signals
    end

    def initialize(worker, handler)
      @worker = worker
      @handler = handler
    end

    def trap_signals(signals = nil)
      if signals.nil?
        trap_signals(COMMON_SIGNALS)
        trap_signals(JRUBY_SIGNALS) unless defined?(JRUBY_VERSION)
        trap_signals(OPTIONAL_SIGNALS)
      else
        signals.each { |sig| trap_signal(sig) }
      end

    rescue ArgumentError
      warn "Signals are not supported: #{signals.inspect}"
    end

    def trap_signal(sig)
      trap_method = "trap_#{sig}"
      return unless @handler.respond_to?(trap_method)

      @worker.debug { ['signals.setup', {:signal => sig}] }

      trap sig do
        @worker.debug { ['signals.trap', {:signal => sig}] }
        @handler.send(trap_method, @worker)
      end
    end
  end
end

