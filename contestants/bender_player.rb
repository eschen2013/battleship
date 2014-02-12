require 'logger'
require 'pry'

class BenderPlayer
  def initialize
    @log = Logger.new("test.txt")
  end

  def name
    "Bender Bending Rodríguez"
  end

  def new_game
    # return an array of 5 arrays containing
    # [x,y, length, orientation]
    # e.g.
    @mode = :seek #, :target, :destroy
    @available = all_coords
    @history = []
    @ships = [5, 4, 3, 3, 2]
    @sank = []
    [
      [0, 0, 5, :down],
      [4, 4, 4, :across],
      [9, 3, 3, :down],
      [2, 2, 3, :across],
      [9, 7, 2, :down]
    ]
  end

  def all_coords
    coords = []
    (0..9).each do |y|
      (0..9).each do |x|
        coords << [x, y]
      end
    end
    coords
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
    log "lines: #{lines.inspect}"
    lines.uniq
  end

  def hits
    hits = by_status(:hit) - sank_coords
    log "hits: #{hits.inspect}"
    hits
  end

  def sank_coords
    coords = []
    @sank.each{ |ship| coords += ship_coords(ship) }
    log "sank coords: #{coords.inspect}"
    coords
  end

  def ship_coords(ship)
    case ship[3]
    when :across
      ship[2].times.map {|x| [ship[0] + x, ship[1]] }
    when :down
      ship[2].times.map {|y| [ship[0], ship[1] + y] }
    end
  end

  def take_turn(state, ships_remaining)
    log "start turn"
    @state = state
    handle_sinking_ships(ships_remaining)
    run_scores
    coord = seek
    @history << @available.delete(coord)
    log "end turn #{coord.inspect} #{@scores[coord]}"
    coord
  end

  def handle_sinking_ships(remaining)
    sank = (@ships - remaining).first
    if sank
      last = @history.last
      possible_ships = lines.select do |line|
        ship_coords(line).member?(last) &&
        line[2] == sank # same length
      end
      log "sank #{sank}, possible matches: #{possible_ships.inspect}"
      @sank << possible_ships.first if possible_ships.one?
    end
    @ships = remaining
  end

  def run_scores
    init_scores
    score_miss_neighbors
    score_hit_neighbors
    score_line_endings
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
      line_extensions(line).each{ |coord| add_score(coord, 10) }
    end
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

  def init_scores
    @scores = Hash.new(0)
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

  def log(msg)
    @log.info msg
  end

end
