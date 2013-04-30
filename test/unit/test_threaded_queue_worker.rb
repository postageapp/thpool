require_relative '../helper'

class TestEmThreadedQueueWorker < Test::Unit::TestCase
  def test_defaults
    pool = EmThreadedQueue::Pool.new
    args = %w[ test arguments ]

    worker = EmThreadedQueue::Worker.new(pool, *args)

    assert_equal pool, worker.pool
    assert_equal nil, worker.block
    assert_equal args, worker.args
  end
end
