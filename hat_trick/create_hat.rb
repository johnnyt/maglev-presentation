# Create a hat to hold rabbits. It can hold other things, too.
#
# This file sets up the hat trick by doing the following:
#
# 1: Load the Hat class and save it to the repository.
# 2: Load the Rabbit class and save it to the repository.
# 3: Create an instance of the Hat, and attach it to a persistent root.
# 4: Commit results of actions 1, 2 and 3.
#
# At the end of this code, the Hat class, the Rabbit class and an empty
# instance of a Hat are available to all MagLev VMs attached to the stone.
# VMs that are already running will need to do a
# <tt>Maglev.abort</tt> to refresh their views. New VMs will simply see
# the classes and the hat.
#
# This file needs to be run only once per repository. Running it multiple
# times is not a problem, but it will replace the hat with an empty one.
#
Maglev.persistent do
  load 'hat.rb'
  load 'rabbit.rb'
end
Maglev[:hat] = Hat.new
Maglev.commit

puts ""
puts "Commited the Hat and Rabbit classes"
puts "and persisted a new hat to Maglev[:hat]"
puts ""
