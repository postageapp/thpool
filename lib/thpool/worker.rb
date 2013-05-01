class Thpool::Worker
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
        self.after_initialize

        while (block = @pool.block_pop)
          begin
            @block = block
            self.before_perform(block)
            perform(&block)
            self.after_perform(block)
            @block = nil

            unless (@pool.worker_needed?(self))
              @pool.worker_finished!(self)
              break
            end
          rescue => exception
            @pool.handle_exception(self, exception, block)
          end
        end
      rescue => exception
        @pool.handle_exception(self, exception, nil)
      end
    end
  end

  # Calls the Proc pulled from the queue. Subclasses can implement their own
  # method here which might pass in arguments to the block for contextual
  # purposes.
  def perform
    yield(*@args)
  end

  # This method is called after the worker is initialized within the thread
  # used by the worker. It can be customized in sub-classes as required.
  def after_initialize
  end

  # This method is called just before the worker executes the given block.
  # This should be customized in sub-classes to do any additional processing
  # required.
  def before_perform(block)
  end

  # This method is called just after the worker has finished executing the
  # given block This should be customized in sub-classes to do any additional
  # processing required.
  def after_perform(block)
  end

  # Called by the pool to reap this thread when it is finished.
  def join
    @thread.join
  end
end
