module QueueKit
  module Instrumentable
    def instrumenter_from(options)
      @instrumenter = options.fetch(:instrumenter) { default_instrumenter }
      if options.fetch(:debug) { false }
        enable_debug_mode
      end
    end

    def instrument(name, payload = nil)
      options = default_instrument_options.dup
      options.update(payload) if payload
      @instrumenter.instrument("queuekit.#{name}", options)
    end

    def force_debug
      instrument(*yield)
    end

    def debug
    end

    def enable_debug_mode
      class << self
        alias debug force_debug
      end
    end

    def default_instrument_options
      {:worker => self}
    end

    def default_instrumenter
      PutsInstrumenter.new
    end

    class PutsInstrumenter
      def instrument(name, payload = nil)
        puts "[#{Time.now}] #{name}: #{payload.inspect}"
      end
    end
  end
end
