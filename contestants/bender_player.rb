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

  def take_turn(state, ships_remaining)
    @state = state
    weighted.first
  end

  def available
    available = []
    @state.each_with_index do |row, y|
      row.each_with_index do |state, x|
        available << [x, y] if state == :unknown
      end
    end
    available
  end

  def weighted
    available.sort_by do |coord|
      score = 0
      neighbors(coord).each do |neighbor|
        case at(neighbor)
        when :miss
          score -= 1
        when :hit
          score += 2
        end
      end
      score * -1
    end
  end

  def neighbors(coord)
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
