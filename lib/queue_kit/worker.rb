module QueueKit
  class Worker
    def initialize(options = {})
      @queue = options.fetch(:queue) { [] }
      @on_pop = options.fetch(:on_pop) {}
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

    def work
      item = @queue.pop
      @on_pop.call(item) if item
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

