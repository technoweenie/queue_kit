module QueueKit
  class Worker
    def initialize(options = {})
      @queue = options.fetch(:queue) { [] }
      @on_pop = options.fetch(:on_pop) {}
      @on_error = options.fetch(:on_error) { lambda { |e| raise e } }
      @after_work = options.fetch(:after_work) { lambda {} }
      @stopped = true
    end

    def run
      start
      loop do
        working? ? work : break
        @after_work.call
      end
    end

    def on_pop(&block)
      @on_pop = block
    end

    def on_error(&block)
      @on_error = block
    end

    def after_work(&block)
      @after_work = block
    end

    def work
      item = @queue.pop
      @on_pop.call(item) if item
    rescue Exception => exception
      @on_error.call(exception)
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
  end
end

