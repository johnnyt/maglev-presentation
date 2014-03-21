class Worker
  def self.work(sleep_time=1)
    self.new(sleep_time).work
  end

  def initialize(sleep_time=1)
    @sleep_time = sleep_time
  end

  def work
    loop do
      if job = Job.next
        puts "\nProcessing job"
        job.call
      else
        print '.'
        sleep @sleep_time
      end
    end
  end
end
