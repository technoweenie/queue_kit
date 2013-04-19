require 'bundler'
require 'test/unit'
require File.expand_path("../../lib/queue_kit", __FILE__)

class NullInstrumenter
  def instrument(name, payload = nil)
  end
end

