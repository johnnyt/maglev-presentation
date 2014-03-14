require 'rubygems'
require 'sinatra'
require 'sinatra/json'
require './models/cell'
require './models/player'

helpers Sinatra::JSON

helpers do
  def cell_hashes(cells, current_cell=nil)
    minx = cells.collect{|cell|cell.geo.x}.min
    miny = cells.collect{|cell|cell.geo.y}.min

    cells.collect do |cell|
      cell_class = if current_cell && cell == current_cell
                     'current'
                   else
                     ''
                   end

      {
        :geoX => cell.geo.x,
        :geoY => cell.geo.y,
        :x => cell.geo.x - minx,
        :y => cell.geo.y - miny,
        :geohash => cell.geohash,
        :class => cell_class
      }
    end
  end

  def children(current_cell)
    cell_hashes(current_cell.children_array, current_cell['0'])
  end

  def grandchildren(current_cell)
    cell_hashes(current_cell.grandchildren, current_cell['00'])
  end

  def siblings(current_cell)
    cell_hashes(current_cell.siblings, current_cell)
  end

  def nephews(current_cell)
    cell_hashes(current_cell.nephews, current_cell)
  end

  def cousins(current_cell)
    cell_hashes(current_cell.cousins, current_cell)
  end
end

get '/' do
  File.read('index.html')
end

get '/map' do
  geohash = if params[:geohash]
              params[:geohash]
            elsif params[:lat] && params[:lng]
              Geohash.from(params[:lat], params[:lng], 6).to_s
            else
              '9x0qy9'
            end

  cur_cell = GeoCell[geohash]
  cells = params[:gen] && params[:gen] == 'children' ?
    grandchildren(cur_cell) :
    nephews(cur_cell)

  json cells
end
