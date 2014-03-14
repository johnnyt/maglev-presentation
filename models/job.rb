require 'maglev/rcqueue'

module JobQueue
  # See maglev/src/kernel/bootstrap/System.rb for info on
  # persistent shared counters.
  #
  # The value of 50 has no special meaning. There are 128
  # shared counters: 1-128 - any can be used
  def counter_number
    @counter_number ||= 50
  end

  def size
    Maglev::System.pcounter(counter_number)
  end

  def jobs
    Maglev[:jobs] ||= RCQueue.new
  end

  def add(&block)
    lock{ jobs << block }
    increment_counter
  end

  def perform_next_job
    job = lock{ jobs.shift }
    return if job.nil?
    decrement_counter
    job.call
  end

  def increment_counter
    Maglev::System.increment_pcounter(counter_number)
  end

  def decrement_counter
    Maglev::System.decrement_pcounter(counter_number)
  end

  def lock(&block)
    Maglev.abort
    result = block.call
    Maglev.commit
    result
  rescue Maglev::CommitFailedException
    retry
  end
end

class Job
  extend JobQueue

  def work
    while true
      (size > 0) ?
        perform_next_job :
        sleep(1)
    end
  end
end
