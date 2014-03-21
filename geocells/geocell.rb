class Geocell
  ROOT_KEY = :geocell_root

  attr_accessor :char, :parent, :kids

  def self.root
    Maglev[ROOT_KEY] ||= self.new
  end

  def self.[](hash_string)
    root[hash_string]
  end

  def initialize(parent=nil, char='')
    @parent, @char = parent, char
    @kids = Hash.new
  end

  def [](hash_string)
    return self if hash_string.nil? || hash_string == ''
    lookup = hash_string.slice! 0
    return kids[lookup][hash_string]
  end

  def geohash
    (parent.nil? ? '' : parent.geohash) + char
  end
end

