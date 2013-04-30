class EmThreadedQueue::Worker
  # == Properties ===========================================================

  attr_reader :pool
  attr_reader :args
  attr_reader :block

  # == Instance Methods =====================================================

  # Creates a new worker attached to the provided pool. Optional arguments
  # may be supplied, which are passed on to the blocks it processes.
  def initialize(pool, *args)
    @pool = pool
    @args = args

    @thread = Thread.new do
      Thread.abort_on_exception = true
      begin
        while (block = @pool.block_pop)
          begin
            @block = block
            perform(&block)
            @block = nil

            unless (@pool.worker_needed?(self))
              @pool.worker_finished!(self)
              break
            end
          rescue => exception
            @pool.report_exception!(self, exception, block)
          end
        end
      rescue => exception
        @pool.report_exception!(self, exception)
      end
    end
  end

  # Calls the Proc pulled from the queue. Subclasses can implement their own
  # method here which might pass in arguments to the block for contextual
  # purposes.
  def perform
    yield(*@args)
  end

  # Called by the pool to reap this thread when it is finished.
  def join
    @thread.join
  end
end
