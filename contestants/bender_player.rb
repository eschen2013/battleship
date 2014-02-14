require "pry"
require "bender"

class BenderPlayer
  def initialize
    # @logger = Logger.new(STDOUT)
  end

  def name
    "Bender Bending Rodríguez"
  end

  def new_game
    @available = all_coords
    @history = []
    @ships = [5, 4, 3, 3, 2]
    @sank = []
    @game = Bender::Game.new
    place_ships
  end

  def take_turn(state, ships_remaining)
    @state = state
    @game.update(state)
    handle_sinking_ships(ships_remaining)
    run_scores
    coord = seek
    @history << @available.delete(coord)
    coord
  end

  # def log(msg)
  #   @logger.info msg
  # end

  def all_coords
    coords = []
    (0..9).each do |y|
      (0..9).each do |x|
        coords << [x, y]
      end
    end
    coords
  end

  def place_ships
    placements = []
    @ships.each do |size|
      placed_coords = ship_coords(*placements)
      placements << random_shipper(size).detect do |ship|
        ship_coords(ship).none?{ |c| placed_coords.member? c }
      end
    end
    placements
  end

  def random_ship(size)
    max = 10 - (size - 1)
    if rand(2) == 0
      [rand(max), rand(10), size, :across]
    else
      [rand(10), rand(max), size, :down]
    end
  end

  def random_shipper(size)
    Enumerator.new do |y|
      loop do
        y << random_ship(size)
      end
    end
  end

  def hits
    by_status(:hit) - sank_coords
  end

  def sank_coords
    ship_coords(*@sank)
  end

  def ship_coords(*ships)
    coords = []
    ships.each do |ship|
      coords += case ship[3]
                when :across
                  ship[2].times.map {|x| [ship[0] + x, ship[1]] }
                when :down
                  ship[2].times.map {|y| [ship[0], ship[1] + y] }
                end
    end
    coords
  end

  def handle_sinking_ships(remaining)
    remaining = remaining.sort
    sank = nil
    if @ships.size != remaining.size
      @ships.sort.each_with_index do |size, i|
        if size != remaining[i]
          sank = size
          break
        end
      end
    end
    if sank
      last = @history.last
      possible_ships = lines.select do |line|
        ship_coords(line).member?(last) &&
        line[2] == sank # same length
      end
      @sank << possible_ships.first if possible_ships.one?
    end
    @ships = remaining
  end

  def run_scores
    init_scores
    score_miss_neighbors
    score_miss_neighbors2
    score_hit_neighbors
    score_line_endings
  end

  def init_scores
    @scores = Hash.new(0)
  end

  def score_miss_neighbors2
    @game.run_scores
  end

  def score_miss_neighbors
    by_status(:miss).each do |miss|
      adjacent(miss).each{ |coord| add_score(coord, -1) }
    end
  end

  def score_hit_neighbors
    hits.each do |hit|
      adjacent(hit).each{ |coord| add_score(coord, 3) }
    end
  end

  def score_line_endings
    lines.each do |line|
      line_extensions(line).each do |coord|
        add_score(coord, 10) if line[2] < @ships.max
      end
    end
  end

  def add_score(coord, score)
    @scores[coord] += score
  end

  def seek
    sorted = @available.sort_by{ |c| @scores[c] * -1 }
    score = @scores[sorted.first]
    sorted.take_while{ |c| @scores[c] == score }.sample
  end

  def north_of(coord)
    [ coord[0], coord[1] - 1 ]
  end

  def west_of(coord)
    [ coord[0] - 1, coord[1] ]
  end

  def east_of(coord)
    [ coord[0] + 1, coord[1] ]
  end

  def south_of(coord)
    [ coord[0], coord[1] + 1 ]
  end

  def adjacent(c)
    [north_of(c), east_of(c), south_of(c), west_of(c)].select{|d| valid?(d) }
  end

  def at(coord)
    @state[ coord[1] ][ coord[0] ]
  end

  def by_status(status)
    all_coords.select {|coord| at(coord) == status }
  end

  def valid?(coord)
    coord.all?{|i| i >= 0 && i < 10 }
  end

  def line_extensions(line)
    coords = []
    x, y = line.first(2)
    a, b = nil, nil
    case line[3]
    when :across
      a = west_of([x, y])
      b = [x + line[2], y]
    when :down
      a = north_of([x, y])
      b = [x, y + line[2]]
    end
    [a, b].select{|c| @available.member?(c) }
  end

  def lines
    hits = self.hits.sort
    lines = []
    hits.each do |coord|
      unless hits.member?( west_of(coord) )
        east = east_of(coord)
        across = nil
        while hits.member?(east)
          across ||= coord + [1, :across]
          across[2] += 1
          east = east_of(east)
        end
        lines << across if across
      end

      unless hits.member?( north_of(coord) )
        south = south_of(coord)
        down = nil
        while hits.member?(south)
          down ||= coord + [1, :down]
          down[2] += 1
          south = south_of(south)
        end
        lines << down if down
      end
    end
    lines.uniq
  end
end
