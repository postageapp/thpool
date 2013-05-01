require 'thread'

class Thpool
  # == Submodules ===========================================================

  autoload(:Worker, 'thpool/worker')

  # == Constants ============================================================

  OPTIONS_DEFAULT = {
    :worker_class => Thpool::Worker,
    :workers_min => 0,
    :workers_max => 20,
    :count_per_worker => 1,
    :args => [ ]
  }

  # == Properties ===========================================================

  attr_reader *OPTIONS_DEFAULT.keys

  # == Instance Methods =====================================================

  # Creates a new instance of Pool with an optional set of options:
  # * :worker_class - The class of worker to spawn when tasks arrive.
  # * :workers_min - The minimum number of workers to have running.
  # * :workers_max - The maximum number of workers to spawn.
  # * :count_per_worker - Ratio of items in queue to workers.
  # * :args - An array of arguments to be passed through to the workers.
  def initialize(options = nil)
    @queue = Queue.new
    @workers = [ ]

    options = options ? OPTIONS_DEFAULT.merge(options) : OPTIONS_DEFAULT

    @worker_class = options[:worker_class]
    @workers_min = options[:workers_min]
    @workers_max = options[:workers_max]
    @count_per_worker = options[:count_per_worker]
    @args = options[:args]

    @workers_min.times do
      self.worker_create!
    end
  end

  # Returns the number of active worker threads.
  def workers_count
    @workers.length
  end

  # Returns the number of workers required for the current loading.
  def workers_needed
    n = ((@queue.length + @workers.length - @queue.num_waiting) / @count_per_worker)

    if (n > @workers_max)
      @workers_max
    elsif (n < @workers_min)
      @workers_min
    else
      n
    end  
  end

  # Makes a blocking call to pop an item from the queue, returning that item.
  # If the queue is empty, also has the effect of sleeping the calling thread
  # until something is pushed into the queue.
  def block_pop
    @queue.pop
  end

  # Returns true if more workers are needed to satisfy the current backlog,
  # or false otherwise.
  def workers_needed?
    @workers.length < self.workers_needed
  end

  def worker_needed?(worker)
    @queue.length > 0 or @workers.length <= self.workers_needed
  end

  # Returns an array of the current workers.
  def workers
    @workers.dup
  end

  # Returns the current number of workers.
  def workers_count
    @workers.length
  end

  # Returns true if there are any workers, false otherwise.
  def workers?
    @workers.any?
  end

  # Returns true if there is some outstanding work to be performed, false
  # otherwise.
  def busy?
    @queue.num_waiting < @workers.length
  end

  # Returns the number of workers that are waiting for something to do.
  def waiting
    @queue.num_waiting
  end

  # Returns true if anything is queued, false otherwise. Note that this does
  # not count anything that might be active within a worker.
  def queue?
    @queue.length > 0
  end

  # Returns the number of items in the queue. Note that this does not count
  # anything that might be active within a worker.
  def queue_size
    @queue.size
  end
  
  # Receives reports of exceptions from workers. Default behavior is to re-raise.
  def report_exception!(worker, exception, block = nil)
    raise(exception)
  end

  # Schedules a block to be acted upon by the workers.
  def perform
    @queue << Proc.new

    if (self.workers_count < self.workers_needed)
      self.worker_create!
    end

    true
  end

  # Called by a worker when it's finished. Should not be called otherwise.
  def worker_finished!(worker)
    @workers.delete(worker)
    worker.join
  end

protected
  # Creates a new worker and puts it into the list of available workers.
  def worker_create!
    @workers << worker_class.new(self, *@args)
  end
end
