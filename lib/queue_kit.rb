module QueueKit
  VERSION = "0.0.3"
  ROOT = File.expand_path("../queue_kit", __FILE__)

  def self.require_lib(*libs)
    libs.each do |lib|
      require File.join(ROOT, lib.to_s)
    end
  end

  class << self
    alias require_libs require_lib
  end

  require_lib "worker"
end

