module DasBoot
  class BoardCell
    attr_accessor :value, :hunt_probability, :target_probability

    def initialize(value)
      @hunt_probability = 0
      @target_probability = 0
      @value = value
    end
  end

  class BoardRow
    attr_accessor :row

    def initialize(row)
      @row = []
      row.each do |cell|
        @row << BoardCell.new(cell)
      end
    end

    def [](x)
      @row[x]
    end

    def []=(x, value)
      @row[x] = BoardCell.new(value)
    end

    def each(&block)
      @row.each(&block)
    end
  end

  class Board
    HIT     = :hit
    MISS    = :miss
    UNKNOWN = :unknown

    DESTROYED = :destroyed

    DOWN  = [0,1]
    UP    = [0,-1]
    LEFT  = [-1,0]
    RIGHT = [1,0]

    attr_accessor :rows

    def initialize(matrix)
      @rows = []
      matrix.each do |row|
        @rows << BoardRow.new(row)
      end
    end

    def [](y)
      @rows[y]
    end
  
    def fit?(x, y, xstep, ystep, size)
      if size == 0
        true
      elsif x >= 0 && x <= 9 && y >= 0 && y <= 9 && @rows[y][x].value == UNKNOWN
        fit?(x + xstep, y + ystep, xstep, ystep, size -1)
      else
        false
      end
    end

    def possibly_fit?(x,y,xstep,ystep,size)
      if size == 0
        true
      elsif x >= 0 && x <= 9 && y >= 0 && y <= 9 && (@rows[y][x].value != MISS && @rows[y][x].value != DESTROYED)
        possibly_fit?(x + xstep, y + ystep, xstep, ystep, size -1)
      else
        false
      end
    end

    def inc!(x, y, xstep, ystep, size, mode = :hunt)
      while size > 0
        if mode == :hunt
          @rows[y][x].hunt_probability += 1
        else
          @rows[y][x].target_probability += 1
        end
        x += xstep
        y += ystep
        size -= 1
      end
    end

    def calculate_hunt(ships)
      10.times do |r|
        10.times do |c|
          ships.each do |ship|
            [DOWN, UP, LEFT, RIGHT].each do |dir|
              if fit?(r, c, dir.first, dir.last, ship)
                inc!(r,c, dir.first, dir.last, ship, :hunt)
              end
            end
          end
        end
      end
    end

    def number_of_hits_in(x, y, xstep, ystep, s)
      if s == 0
        0
      elsif @rows[y][x].value == HIT
        1 + number_of_hits_in(x + xstep, y+ystep, xstep, ystep, s-1)
      else
        0 + number_of_hits_in(x + xstep, y + ystep, xstep, ystep, s -1)
      end
    end

    def calculate_target(hit_x, hit_y, ships)
      hits = []
      10.times do |r|
        10.times do |c|
          hits << [r,c] if @rows[r][c].value == HIT
        end
      end


      hits.each do |hit|
        [DOWN, UP, LEFT, RIGHT].each do |dir|
          ships.each do |ship|
            x = hit.last
            y = hit.first

            ship.times do |s|
              if possibly_fit?(x,y,dir.first, dir.last, s)
                ci = number_of_hits_in(x,y,dir.first, dir.last, s)
                (ci + 1).times do
                  inc!(x,y,dir.first, dir.last, s, :target)
                end
              end
      
              x -= dir.first
              y -= dir.last
            end
          end
        end
      end

      10.times do |r|
        10.times do |c|
          @rows[r][c].target_probability = 0 if @rows[r][c].value == HIT
        end
      end
    end

    def hit_coords
      hc = []
      10.times do |r|
        10.times do |c|
          hc << [c,r] if @rows[r][c].value == HIT
        end
      end

      hc
    end

    def hit_count
      hc = 0
      10.times do |r|
        10.times do |c|
          hc += 1 if @rows[r][c].value == HIT
        end
      end
  
      hc
    end

    def within_bounds?(x, y)
      x >= 0 && x <= 9 && y >= 0 && y <= 9
    end

    def hit?(x,y)
      within_bounds?(x,y) && @rows[y][x] == HIT
    end

    def miss?(x,y)
      within_bounds?(x,y) && @rows[y][x] == MISS
    end

    def unknown?(x,y)
      within_bounds?(x,y) && @rows[y][x] == UNKNOWN
    end

    def hunt
      max = 0
      maxes = []
      10.times do |r|
        10.times do |c|  
          v = @rows[r][c].hunt_probability

          if v >= max
            max = v
          end
        end
      end

      10.times do |r|
        10.times do |c|
          v = @rows[r][c].hunt_probability
          if v == max
            maxes << [c,r]
          end
        end
      end

      if maxes.length == 0
        [0,0]
      else
        maxes.sample
      end
    end

    def targetable?
      max = 0
      10.times do |r|
        10.times do |c|
          v = @rows[r][c].target_probability
          
          if v >= max
            max = v
          end
        end
      end

      max != 0
    end
  
    def target
      max = 0
      maxes = []

      10.times do |r|
        10.times do |c|
          v = @rows[r][c].target_probability
          
          if v >= max
            max = v
          end
        end
      end

      10.times do |r|
        10.times do |c|
          v = @rows[r][c].target_probability
          if v == max
            maxes << [c,r]
          end
        end
      end

      if maxes.length == 0
        [0,0]
      else
        maxes.sample
      end
    end

    def replace_with_destroyed!(coords)
      coords.each do |(c,r)|
        @rows[r][c].value = DESTROYED if @rows[r][c].value == HIT
      end
    end

    def debug(mode = :hunt)
      puts "=" * 20
      @rows.each do |row|
        row.each do |cell|
          printf "#{mode == :hunt ? cell.hunt_probability : cell.target_probability} "
        end
        puts
      end
      puts "=" * 20
    end

    def log_debug(mode = :hunt)
      open('./das_boot.log', 'a') do |f|
        f.puts "=" * 20
        @rows.each do |row|
          row.each do |cell|
            f.printf "#{mode == :hunt ? cell.hunt_probability : cell.target_probability} "
          end
          f.puts
        end
        f.puts "=" * 20
      end
    end
  end
end

class DasBootPlayer
  HUNT = :hunt
  TARGET = :target
  
  attr_accessor :mode, :last_turn_hc, :targetting, :last_move, :move, :move_count, :last_ship_count, :sunk_ship, :last_ships, :destroyed

  def name
    "Das Boot"
  end

  def new_game
    @move_count = 0
    @mode = HUNT
    @last_turn_hc = 0
    @last_move = nil
    @targetting = nil
    @move = nil
    @last_ship_count = 5
    @last_ships = [5,4,3,3,2]
    @destroyed = []

    [
      [
        [0, 0, 5, :down],
        [4, 4, 4, :across],
        [9, 3, 3, :down],
        [2, 2, 3, :across],
        [9, 7, 2, :down]
      ],
      [
        [2, 4, 4, :down],
        [4, 1, 3, :down],
        [6, 1, 3, :down],
        [5, 7, 2, :down],
        [8, 3, 5, :down]
      ],
      [
        [1, 0, 2, :across],
        [4, 1, 3, :down],
        [2, 4, 3, :down],
        [0, 8, 4, :across],
        [5, 9, 5, :across]
      ],
      [
        [1, 1, 3, :down],
        [2, 5, 3, :down],
        [4, 3, 4, :across],
        [6, 1, 2, :across],
        [5, 7, 5, :across]
      ],
      [
        [1, 1, 3, :down],
        [8, 1, 3, :down],
        [0, 7, 4, :across],
        [4, 6, 2, :down],
        [5, 7, 5, :across]
      ],
      [
        [2, 3, 3, :down],
        [7, 3, 3, :down],
        [3, 3, 4, :across],
        [3, 6, 5, :across],
        [0, 9, 2, :across]
      ],
      [
        [6, 1, 3, :across],
        [6, 2, 3, :across],
        [8, 4, 4, :down],
        [2, 8, 5, :across],
        [1, 4, 2, :down]
      ],
      [
        [2, 2, 3, :across],
        [5, 4, 2, :down],
        [1, 7, 3, :across],
        [5, 8, 4, :across],
        [8, 2, 5, :down]
      ],
      [
        [1, 0, 2, :down],
        [5, 0, 5, :across],
        [7, 3, 3, :down],
        [1, 4, 3, :across],
        [0, 9, 4, :across]
      ],
      [
        [1, 0, 5, :down],
        [6, 0, 4, :across],
        [4, 4, 3, :across],
        [2, 7, 3, :across],
        [8, 9, 2, :across]
      ],
      [
        [2, 1, 3, :down],
        [6, 0, 2, :across],
        [1, 5, 3, :down],
        [3, 7, 5, :across],
        [9, 3, 4, :down]
      ]
    ].sample
  end

  def hunting?
    @mode == HUNT
  end
  
  def targeting?
    !hunting?
  end

  def take_turn(state, ships_remaining)
    @move_count += 1
    board = DasBoot::Board.new(state)

    board.replace_with_destroyed!(@destroyed)

    if @last_turn_hc < board.hit_count
      if @last_ships.size > ships_remaining.size
        ls = @last_ships.dup
        ships_remaining.each {|sr| ls.delete_at(ls.index(sr))}
        @sunk_ship = ls.first
        @last_ships = ships_remaining


        if board.hit_count == @sunk_ship
          board.hit_coords.each {|h| @destroyed << h}
          board.replace_with_destroyed!(@destroyed)
          @mode = HUNT
        else
          @destroyed << @last_move
          board.replace_with_destroyed!(@destroyed)
          @mode = TARGET
        end
      else
        @mode = TARGET
      end
    end

    if targeting?
      board.calculate_target(@last_move.first, @last_move.last, ships_remaining.dup)
      if board.targetable?
        @move = board.target
      else
        @mode = HUNT
      end
    end

    if hunting?
      board.calculate_hunt(ships_remaining.dup)
      @move = board.hunt
    end

    @last_move = @move
    @last_ship_count = ships_remaining.size
    @last_turn_hc = board.hit_count
    @move
  end

  def log(msg)
    File.write('das_boot.log', msg, File.size('./das_boot.log'), mode: 'a')
  end
end
