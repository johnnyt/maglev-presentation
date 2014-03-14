load File.expand_path "../geohash.rb", __FILE__

class Cell
  ALPHABET = '0123456789bcdefghjkmnpqrstuvwxyz'.split ''

  attr_accessor :character, :parent, :children_hash, :geo, :contents

  def self.root
    @root ||= new
  end

  def self.[](hash_string)
    root[hash_string]
  end

  def self.generate(depth=1, kids=ALPHABET)
    kids = kids.split '' if kids.kind_of?(String)
    kid_count = 0
    kids.each do |char|
      kid_count += root.children_hash[char].generate_children depth-1
      Maglev.commit
    end
    kid_count
  end

  def initialize(parent=nil, char='')
    @parent, @character = parent, char
  end

  def [](hash_string)
    return self if hash_string.nil? || hash_string == ''
    lookup = hash_string.slice! 0
    return children_hash[lookup][hash_string]
  end

  def generate_children(generations_left=1)
    return 1 if generations_left <= 0
    # accessing children causes them to be created
    children_hash.inject(0) do |kid_count,key_value|
      char,child = *key_value
      kid_count += child.generate_children(generations_left-1)
      kid_count
    end
  end

  def siblings
    parent.nil? ? [self] : parent.children
  end

  def cousins
    parent.parent.grandchildren
  end

  def nephews
    siblings.inject([]) do |arr,sib|
      arr.push *sib.children
    end
  end

  def grandchildren
    children.inject([]) do |arr,kid|
      arr.push *kid.children
    end
  end

  def children
    children_hash.inject([]){ |arr,pair| arr << pair.last }
  end

  def children_hash
    @children_hash ||= ALPHABET.inject({}) do |hsh,char|
      hsh[char] = self.class.new self, char
      hsh
    end
  end

  def geohash
    (parent.nil? ? '' : parent.geohash) + character
  end

  def inspect
    %Q!#<GeoCell:#{geohash} kids?="#{has_children?}">!
  end

  def geo
    @geo ||= Geohash[geohash]
  end

  def has_children?
    !@children_hash.nil?
  end

  def contents
    @contents ||= IdentitySet.new
  end

  def add_content(content)
    contents.add content
  end

  def remove_content(content)
    contents.delete content
  end
end

Cell.root.generate_children
