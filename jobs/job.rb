require 'maglev/rcqueue'

class Job
  def self.queue
    Maglev[:jobs] ||= RCQueue.new
  end

  def self.add(&block)
    self.lock{ queue << block }
    size
  end

  def self.next
    self.lock{ queue.shift }
  end

  def self.lock(&block)
    Maglev.abort
    result = block.call
    Maglev.commit
    result
  end

  def self.size
    queue.size
  end
end
