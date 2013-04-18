require File.expand_path("../../lib/queue_kit", __FILE__)
QueueKit.require_lib 'signal_handlers/graceful_quit'

queue = Object.new
def queue.pop
  rand 10
end

processor = lambda { |num| sleep 1; puts num }

worker = QueueKit::Worker.new queue, :debug => ENV['DEBUG'] == '1',
  :processor => processor

QueueKit::SignalChecker.trap(worker, QueueKit::GracefulQuit)

puts "Starting on #{Process.pid}..."
worker.run

