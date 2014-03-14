class Geohash
  BITS = [0x10, 0x08, 0x04, 0x02, 0x01]
  BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"
  NEIGHBORS = {
    :right  => { :even => "bc01fg45238967deuvhjyznpkmstqrwx", :odd => "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
    :left   => { :even => "238967debc01fg45kmstqrwxuvhjyznp", :odd => "14365h7k9dcfesgujnmqp0r2twvyx8zb" },
    :top    => { :even => "p0r21436x8zb9dcf5h7kjnmqesgutwvy", :odd => "bc01fg45238967deuvhjyznpkmstqrwx" },
    :bottom => { :even => "14365h7k9dcfesgujnmqp0r2twvyx8zb", :odd => "238967debc01fg45kmstqrwxuvhjyznp" }
  }
  BORDERS = {
    :right  => { :even => "bcfguvyz", :odd => "prxz" },
    :left   => { :even => "0145hjnp", :odd => "028b" },
    :top    => { :even => "prxz"    , :odd => "bcfguvyz" },
    :bottom => { :even => "028b"    , :odd => "0145hjnp" }
  }

  attr_accessor :geohash, :x, :y, :box, :lat, :lng, :precision

  def self.[](geohash)
    new(geohash)
  end

  def self.from(lat,lng,precision=5)
    new(lat,lng,precision)
  end

  def initialize(*args)
    raise ArgumentError.new("A geohash or lat,lng must be provided") if args.size.zero?

    if args.size == 1
      @geohash = args.first
      @precision = @geohash.length
      decode
    else
      @lat = args.shift.to_f
      @lng = args.shift.to_f
      @precision = (args.shift || 1).to_i
      encode
    end
  end

  def decode
    @box = [[-90.0, 90.0], [-180.0, 180.0]]
    is_lng = 1
    positions = ['','']
    geohash.downcase.scan(/./) do |c|
      BITS.each do |mask|
        bit = (BASE32.index(c) & mask).zero? ? 1 : 0
        refine = box[is_lng]
        positions[is_lng] += (bit ^ 1).to_s
        refine[bit] = (refine[0] + refine[1]) / 2
        #p [is_lng, mask, (BASE32.index(c) & mask), bit, positions, positions.map{|pos|pos.to_i(2)}]
        is_lng ^= 1
      end
    end
    @x = positions.first.to_i(2)
    @y = positions.last.to_i(2)
    @box = box.transpose
  end

  def encode
    latlng = [lat, lng]
    @box = [[-90.0, 90.0], [-180.0, 180.0]]
    positions = ['','']
    is_lng = 1
    @geohash = (0...precision).map {
      ch = 0
      5.times do |bit|
        refine = box[is_lng]
        mid = (refine[0] + refine[1]) / 2
        new_bit = latlng[is_lng] > mid ? BITS[bit] : 0
        refine_bit = new_bit.zero? ? 1 : 0
        refine[refine_bit] = mid
        ch |= new_bit
        positions[is_lng] += (refine_bit ^ 1).to_s
        #p [is_lng, BITS[bit], new_bit, positions, box]
        #p [bit, BITS[bit], is_lng, ch, pos_bit, BASE32[ch,1], positions]
        is_lng ^= 1
      end
      BASE32[ch,1]
    }.join

    @x = positions.first.to_i(2)
    @y = positions.last.to_i(2)
    @box = box.transpose
    #p [geohash, x, y, box]
  end

  ##########
  ## Calculate neighbors (8 adjacents) geohash
  def neighbors
    [[:top, :right], [:right, :bottom], [:bottom, :left], [:left, :top]].map{ |dirs|
      point = adjacent(dirs[0])
      [point, adjacent(dirs[1], point)]
    }.flatten
  end

  def adjacent(dir, source_hash=geohash)
    source_hash = source_hash.to_s
    base, lastChr = source_hash[0..-2], source_hash[-1,1]
    type = (source_hash.length % 2)==1 ? :odd : :even
    p [source_hash, dir, type, base, lastChr]
    if BORDERS[dir][type].include?(lastChr)
      p [:before, dir, base]
      base = adjacent(dir, base)
    end

    Geohash.new(base.to_s + BASE32[NEIGHBORS[dir][type].index(lastChr),1])
  end

  def ==(other)
    other.class == self.class &&
      other.geohash == self.geohash
  end

  def to_s
    geohash
  end

  def inspect
    "#<Geohash:#{geohash} #{x},#{y} #{box}>"
  end
end
