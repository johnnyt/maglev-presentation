# This class defines the Magician's Hat.  It is just a container for
# Rabbits, doves and other things Magicians don't keep up their sleeve.
class Hat
  attr_reader :contents

  def initialize
    @contents = []
  end

  def put(item)
    contents << item
    nil
  end
end
