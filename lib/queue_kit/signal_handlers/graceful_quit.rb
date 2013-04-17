require File.expand_path("../../signal_checker", __FILE__)

module QueueKit
  module GracefulQuit
    extend self

    def trap_TERM(worker)
      worker.stop
    end

    alias trap_INT trap_TERM
  end
end

