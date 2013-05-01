require_relative '../helper'

class TestThpoolWorker < Test::Unit::TestCase
  def test_defaults
    pool = Thpool.new
    args = %w[ test arguments ]

    worker = Thpool::Worker.new(pool, *args)

    assert_equal pool, worker.pool
    assert_equal nil, worker.block
    assert_equal args, worker.args
  end
end
