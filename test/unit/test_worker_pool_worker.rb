require_relative '../helper'

class TestEmWorkerPoolWorker < Test::Unit::TestCase
  def test_defaults
    pool = EmWorkerPool.new
    args = %w[ test arguments ]

    worker = EmWorkerPool::Worker.new(pool, *args)

    assert_equal pool, worker.pool
    assert_equal nil, worker.block
    assert_equal args, worker.args
  end
end
