module QueueKit
  class SignalChecker
    SIGNALS = %w(TERM INT QUIT USR1 USR2 CONT)

    attr_reader :worker
    attr_reader :handler

    def self.trap(worker, handler)
      new(worker, handler).trap_signals
    end

    def initialize(worker, handler)
      @worker = worker
      @handler = handler
    end

    def trap_signals
      SIGNALS.each do |sig|
        trap_method = "trap_#{sig}"
        return unless @handler.respond_to?(trap_method)
        trap sig do
          @worker.debug { [:trap, {:signal => sig}] }
          @handler.send(trap_method, @worker)
        end
      end
    end
  end
end

