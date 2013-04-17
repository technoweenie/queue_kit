module QueueKit
  require_lib 'signal_checker'

  module GracefulQuit
    extend self

    def trap_TERM(worker)
      worker.stop
    end

    alias trap_INT trap_TERM
  end
end

