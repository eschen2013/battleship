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
    log "taking turn (mode: #{@mode})"
    @state = state
    @sunk = @ships - ships_remaining
    check_last_move(state) if @history.any?
    coord = send(@mode)
    while @history.member?(coord)
      coord = seek
    end
    @history << coord
    @ships = ships_remaining
    log "attempt (mode: #{@mode}): #{coord.inspect}"
    coord
  end

  def seek
    [rand(10), rand(10)]
  end

  def target
    hit, attempts = nil, []
    @history.reverse_each do |coord|
      result = at(coord)
      if result == :hit
        hit = coord
        break
      end
      attempts << coord
    end
    possible = neighbors(hit) - attempts
    possible.sample
  end

  def destroy
    if at(@history.last) == :miss
      @mode = :seek
      return seek
    end
    a, b = @history.last(2)
    c = b.dup
    if a[0] == b[0] # x (h) stable, y (v) movement
      c[1] += b[1] - a[1]
    else # x (h) movement
      c[0] += b[0] - a[0]
    end
    valid?(c) ? c : seek
  end

  def neighbors(coord)
    n = [coord[0],      coord[1] - 1]
    e = [coord[0] + 1,  coord[1]    ]
    s = [coord[0],      coord[1] + 1]
    w = [coord[0] - 1,  coord[1]    ]
    [n, e, s, w].select{|c| valid?(c) }
  end

  def check_last_move(state)
    if at(@history.last) == :hit
      @mode = case @mode
              when :seek
                :target
              when :target
                :destroy
              else
                :destroy
              end
    end
    @mode = :seek if ship_sank?
  end

  def at(coord)
    @state[ coord[1] ][ coord[0] ]
  end

  def ship_sank?
    @sunk.any?
  end

  def valid?(coord)
    coord.all?{|i| i >= 0 && i < 10 }
  end

  def log(msg)
    @log.info msg
  end

end
