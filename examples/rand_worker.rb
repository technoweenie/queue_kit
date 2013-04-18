require File.expand_path("../../lib/queue_kit", __FILE__)
QueueKit.require_lib 'signal_handlers/graceful_quit'

queue = Object.new
def queue.pop
  rand 10
end

class Worker
  include QueueKit::Worker

  def process(item)
    sleep 1
    puts item
  end
end

worker = Worker.new queue, :debug => ENV['DEBUG'] == '1'
worker.trap QueueKit::GracefulQuit

puts "Starting on #{Process.pid}..."
worker.run

