class EmThreadedQueue::Pool
  def initialize(worker_class, options)
    @worker_class = worker_class
    @options = options
    @queue = [ ]
    @workers = [ ]
  end

  def any?
    @queue.any?
  end

  def empty?
    @queue.empty?
  end

  def size
    @queue.size
  end
  alias_method :length, :size

  def perform(object)
    @queue << [ object, block_given? && Proc.new ]

    if (@workers.empty?)
      @workers << @worker_class.new(@queue, @options)
    end
  end
end
