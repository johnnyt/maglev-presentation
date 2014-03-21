class Generator
  ALPHABET   = '0123456789bcdefghjkmnpqrstuvwxyz'.split ''
  BATCH_SIZE = 50_000

  attr_accessor :depth, :counter, :batch_size

  def self.clobber
    Maglev.root.delete Geocell::ROOT_KEY
    Maglev.commit
    nil
  end

  def self.generate(depth=1, batch=BATCH_SIZE, parent=Geocell.root)
    new(batch).generate(depth, parent)
  end

  def initialize(batch_size)
    @batch_size = batch_size
    @counter = 0
    @start_time = Time.now
  end

  def generate(depth=1, parent=Geocell.root)
    return if depth <= 0

    initialize_kids(parent)
    parent.kids.each do |c,kid|
      generate depth-1, kid
    end

    final_commit(parent)
  end

  def initialize_kids(parent)
    return unless parent.kids.empty?

    ALPHABET.each{ |char| create_cell(parent, char) }
  end

  def create_cell(parent, char)
    parent.kids[char] = Geocell.new(parent, char)
    @counter += 1
    Maglev.commit if (@counter % batch_size).zero?
  end

  def final_commit(parent)
    if parent == Geocell.root
      Maglev.commit
      duration = Time.now - @start_time
      puts "Generated %i cells in %.2f seconds - %i/s" %
            [@counter, duration, (@counter / duration)]
    end
  end
end

