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

      debug :setup, sig

      old_handler = trap sig do
        debug :trap, sig
        @handler.send(trap_method, @worker)
        old_handler.call if old_handler.respond_to?(:call)
      end
    end

    def debug(key, sig)
      @worker.debug { ["signals.#{key}", {:signal => sig}] }
    end
  end
end

