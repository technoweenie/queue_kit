module QueueKit
  class Worker
    class Job < Struct.new(:item, :payload)
      def payload
        self[:payload] ||= {}
      end

      def call?
        !self[:item].nil?
      end
    end

    def initialize(options = {})
      @queue = options.fetch(:queue) { [] }
      @on_pop = options.fetch(:on_pop) {}
      @on_error = options.fetch(:on_error) { method(:default_on_error) }
      @stopped = true
    end

    def run
      start
      loop do
        if working?
          work
        else
          break
        end
      end
    end

    def on_pop(&block)
      @on_pop = block
    end

    def on_error(&block)
      @on_error = block
    end

    def work
      job = Job.new(@queue.pop)
      @on_pop.call(job) if job.call?
    rescue Exception => exception
      @on_error.call(job, exception)
    end

    def start
      if !@on_pop
        raise "Needs something to do with an item.  Set #on_pop"
      end

      @stopped = false
    end

    def stop
      @stopped = true
    end

    def working?
      !@stopped
    end

    def default_on_error(job, exception)
      raise exception
    end
  end
end

