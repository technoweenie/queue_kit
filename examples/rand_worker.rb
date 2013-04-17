require File.expand_path("../../lib/queue_kit", __FILE__)
QueueKit.require_lib 'signal_handlers/graceful_quit'

queue = Object.new
def queue.pop
  rand 10
end

worker = QueueKit::Worker.new :queue => queue, :debug => ENV['DEBUG'] == '1'
worker.on_pop do |num|
  puts num
end

worker.after_work { sleep 1 }

QueueKit::SignalChecker.trap(worker, QueueKit::GracefulQuit)

puts "Starting on #{Process.pid}..."
worker.run

