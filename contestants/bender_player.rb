require 'logger'

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
    @available = build_available
    @history = []
    @ships = [5, 4, 3, 3, 2]
    [
      [0, 0, 5, :down],
      [4, 4, 4, :across],
      [9, 3, 3, :down],
      [2, 2, 3, :across],
      [9, 7, 2, :down]
    ]
  end

  def build_available
    available = []
    (0..9).each do |y|
      (0..9).each do |x|
        available << [x, y]
      end
    end
    available
  end

  def take_turn(state, ships_remaining)
    @state = state

    coord = seek
    @history << @available.delete(coord)
    coord
  end

  def build_scores
    @score_by_coord = {}
    @coords_by_score = {}
    @available.each do |coord|
      score = 0
      score += adjacency_score(coord)
      # score += neighbors_score(coord)
      @score_by_coord[coord] = score
      @coords_by_score[score] ||= []
      @coords_by_score[score] << coord
    end
  end

  def adjacency_score(coord)
    score = 0
    adjacent(coord).each do |a|
      case at(a)
      when :miss
        score -= 1
      when :hit
        score += 3
      end
    end
    score
  end

  def neighbors_score(coord)
    score = 0
    neighbors(coord).each do |n|
      case at(n)
      when :miss
        score -= 1
      when :hit
        score += 0
      end
    end
    score
  end

  def seek
    build_scores
    score = @coords_by_score.keys.max
    @coords_by_score[score].sample
  end

  def neighbors(coord)
    x, y = coord
    n = [y - 2, 0].max
    e = [x - 2, 0].max
    s = [y + 2, 9].min
    w = [x + 2, 9].min
    neighbors = []
    (n..s).each do |y|
      (e..w).each do |x|
        neighbors << [x, y]
      end
    end
    neighbors
  end

  def adjacent(coord)
    n = [coord[0],      coord[1] - 1]
    e = [coord[0] + 1,  coord[1]    ]
    s = [coord[0],      coord[1] + 1]
    w = [coord[0] - 1,  coord[1]    ]
    [n, e, s, w].select{|c| valid?(c) }
  end

  def at(coord)
    @state[ coord[1] ][ coord[0] ]
  end

  def valid?(coord)
    coord.all?{|i| i >= 0 && i < 10 }
  end

  def log(msg)
    @log.info msg
  end

end
