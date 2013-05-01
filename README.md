# Thpool

This is a simple threaded pool worker system that can process tasks in the
order they are received.

## Example

```
pool = Thpool.new

pool.perform do
  # ... Action to be enqueued here
end
```

The worker pool has some sensible defaults as to how many workers will be
created, zero when there's no work, up to twenty when there's enough work
to be performed. These settings can be customized.

Constructor options:

  * `:worker_class` - What kind of worker to spawn. Should be a Worker subclass.
  * `:workers_min` - The minimum number of workers to have running.
  * `:workers_max` - The maximum number of workers to have running.
  * `:count_per_worker` - The ratio of tasks to workers.

The default `EnThpool::Worker` class should suffice for most tasks.
If necessary, this can be subclassed. This would be useful if the worker
needs to perform some kind of resource initialization before it's able to
complete any tasks, such as establishing a database connection.

There is a method `after_initialize` that will execute on the worker thread
immediately after the worker is created. This is useful for performing
post-initialization functions that would otherwise block the main thread:

```
class ExampleDatabaseWorker < Thpool::Worker
  def after_initialize
     # Create a database handle.
     @db = DatabaseDriver::Handle.new

     # Pass in the database handle as the arguments to the blocks being
     # processed.
     @args = [ @db ]
  end
end
```

It's also possible to re-write the `perform` method to pass in additional
arguments.

If you need to do something immediately before or after processing of a block,
two methods are available. As an example this can be used to record the amount
of time it took to complete a task:

```
class ExampleDatabaseWorker < Thpool::Worker
  def before_perform(block)
    @start_time = Time.now
  end

  def after_perform(block)
    puts "Took %ds" % (Time.now - @start_time)
  end
end
```

If exceptions are generated within the worker thread either because of
processing a task or otherwise, these are passed back to the Thpool
object via the `handle_exception` method. The default behavior is to re-raise
these, but it's also possible to perform some additional handling here to
rescue from or ignore them:

```
class ExampleDatabasePool < Thpool
  def handle_exception(worker, exception, block = nil)
    # Pass through to a custom exception logger
    ExceptionHandler.log(exception)
  end
end
```

## Copyright

Copyright (c) 2013 Scott Tadman, The Working Group Inc.
See LICENSE.txt for further details.

