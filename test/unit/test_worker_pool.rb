require_relative '../helper'

class TestWorkerPool < Test::Unit::TestCase
  def test_defaults
    pool = EmWorkerPool.new

    assert_equal false, pool.queue?
    assert_equal 0, pool.queue_size

    assert_equal 0, pool.workers_count
    assert_equal 0, pool.workers_needed
    assert_equal false, pool.workers_needed?
    assert_equal 0, pool.waiting

    assert_equal [ ], pool.workers

    options_default = EmWorkerPool::OPTIONS_DEFAULT

    assert_equal options_default[:worker_class], pool.worker_class
    assert_equal options_default[:workers_min], pool.workers_min
    assert_equal options_default[:workers_max], pool.workers_max
    assert_equal options_default[:count_per_worker], pool.count_per_worker
    assert_equal options_default[:args], pool.args
  end

  class ExampleWorker < EmWorkerPool::Worker
    attr_reader :after_initialized
    attr_reader :before_performed
    attr_reader :after_performed

    def after_initialize
      @after_initialized = :after_initialized
    end

    def before_perform(block)
      @before_performed = :before_performed
    end

    def after_perform(block)
      @after_performed = :after_performed
    end
  end

  def test_options
    pool = EmWorkerPool.new(
      :worker_class => ExampleWorker,
      :workers_min => 1,
      :workers_max => 5,
      :count_per_worker => 2,
      :args => [ :example ]
    )

    assert_equal false, pool.queue?
    assert_equal 0, pool.queue_size

    assert_equal 1, pool.workers_count
    assert_equal 1, pool.workers_needed
    assert_equal false, pool.workers_needed?

    assert_equal ExampleWorker, pool.worker_class
    assert_equal 1, pool.workers_min
    assert_equal 5, pool.workers_max
    assert_equal 2, pool.count_per_worker
    assert_equal [ :example ], pool.args

    worker = pool.workers[0]

    assert worker
    assert worker.is_a?(ExampleWorker)

    assert_equal pool, worker.pool
    assert_equal nil, worker.block
    assert_equal [ :example ], worker.args

    assert_eventually(1) do
      worker.after_initialized
    end

    assert_equal :after_initialized, worker.after_initialized
    assert_equal nil, worker.before_performed
    assert_equal nil, worker.after_performed
  end

  def test_simple_tasks
    pool = EmWorkerPool.new
    count = 0

    100.times do
      pool.perform do
        count += 1
      end
    end

    assert_eventually do
      count == 100
    end
  end

  def test_with_context
    pool = EmWorkerPool.new(
      :args => [ :test, 'arguments' ]
    )

    args = nil

    pool.perform do |*_args|
      args = _args
    end

    assert_eventually(1) do
      args
    end

    assert_equal [ :test, 'arguments' ], args
  end

  def test_with_recursion
    pool = EmWorkerPool.new

    times = 100
    queued = 0
    count = 0

    times.times do |n|
      pool.perform do
        n.times do
          queued += 1
          pool.perform do |*args|
            count += 1
          end
        end
      end
    end

    assert_eventually(600) do
      !pool.queue? and !pool.busy?
    end

    assert_equal (0..times - 1).inject(0) { |s, r| s + r }, queued
    assert_equal queued, count 
  end
end
