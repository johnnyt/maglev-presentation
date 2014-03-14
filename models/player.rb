class Transition
  attr_accessor :player, :cell, :time

  def self.store
    @store ||= IdentitySet.new
  end

  def initialize(player, cell, time=Time.now)
    @player, @cell, @time = player, cell, time
    self.class.store.add self
  end
end

class Player
  attr_accessor :name, :transitions, :current_cell

  def self.store
    @store ||= IdentitySet.new
  end

  def initialize(name)
    @name = name
    @transitions = []
    move_to GeoCell.root
    self.class.store.add self
  end

  def move_to(cell)
    current_cell.remove_content(self) if current_cell
    add_transition cell
    self.current_cell = cell
    cell.add_content self
  end

  def add_transition(cell)
    transitions << Transition.new(self, cell)
  end
end

Transition.store
Player.store
