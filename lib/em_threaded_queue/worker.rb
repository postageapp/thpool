class EmThreadedQueue::Worker
  def initialize(queue, options)
    @queue = queue
    @options = options

    @thread = Thread.new do
      while (entry = @queue.pop)
        object, callback = entry

        result = perform(object)

        if (callback)
          EventMachine.next_tick do
            callback.call(result)
          end
        end
      end
    end
  end

  def perform(object)
    # Implementation specific to worker sub-class
  end
end
