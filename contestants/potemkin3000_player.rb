#require 'logger'

class Potemkin3000Player
  HUNT = :hunt
  STRIKE = :strike
  DIR = [:up,:down,:right,:left]
  attr_accessor :occupied, :fire_state, :strike_dir, :last_move, :first_hit, :last_ships_remaining

  def name
    "Battleship Potemkin 3000"
  end

  def new_game
    @occupied = {}
    @width = 10
    @height = 10
    #file = File.open('potemkin.log', File::WRONLY | File::APPEND | File::CREAT)
    #@logger = Logger.new(file)
    #@logger.level = Logger::WARN
    @state = HUNT
    @last_move = [0,0]
    @last_ships_remaining =5
    ships = []
    ship_size = [5,4,3,3,2]
    ship_size.each do |ship|
      ships << set_ship(ship)
    end
    ships
  end

  def take_turn(state, ships_remaining)
    #was the last move a hit?
    if (state[@last_move[1]][@last_move[0]] == :hit) && (@fire_state==HUNT) #enter strike mode
      @first_hit = @last_move
      @fire_state = STRIKE
    end
    if (ships_remaining != @last_ships_remaining) #we got the ship, return hunt mode
      @fire_state = HUNT
    end

    case @fire_state
      when HUNT
        turn = hunt_turn(state)
      when STRIKE
        turn = strike_turn(state)
    end

    @last_move = turn
    @last_ships_remaining = ships_remaining
    turn
  end

  def random_unknown(state)
    unknowns = []
    @height.times do |h|
      @width.times do |w|
        ##@logger.warn("looking at [#{w},#{h}]")
        if (state[h][w]== :unknown)
          unknowns << [w,h]
        end
      end
    end
    unknowns[rand(unknowns.size)]
  end

  def hunt_turn(state)
    unknowns = []
    @height.times do |h|
      @width.times do |w|
        if (state[h][w]== :unknown) && ((w%2 == 0) && (h%2 == 0) || (w%2 == 1) && (h%2 == 1))
          unknowns << [w,h]
        end
      end
    end
    return random_unknown(state) if unknowns.empty?
    unknowns[rand(unknowns.size)]
  end

  #dumbly pick next iteration
  def move_cand
    move = []
    case DIR[0]
      when :up
        move = [@last_move[0],@last_move[1]-1]
      when :down
        move = [@last_move[0],@last_move[1]+1]
      when :left
        move = [@last_move[0]-1,@last_move[1]]
      when :right
        move = [@last_move[0]+1,@last_move[1]]
    end
    move
  end

  def smart_strike(state)
    if (state[@last_move[1]][@last_move[0]]==:miss)
      @last_move=@first_hit
      DIR.rotate!
    end
    move = move_cand
    counter = 0
    while !valid?(move, state) && counter < 4
      DIR.rotate!
      @last_move = @first_hit
      move = move_cand
      counter+=1
    end
    if counter == 4
      move = rnd_area_strike(state)
    end
    move
  end

  def rnd_area_strike(state)
    #hunt_turn state
    unknowns =[]
    (clamp(@first_hit[1]-4)..clamp(@first_hit[1]+4)).each do |h|
      w = @first_hit[0]
      if (state[h][w]==:unknown)
        unknowns << [w,h]
      end
    end
    (clamp(@first_hit[0]-4)..clamp(@first_hit[0]+4)).each do |w|
      h = @first_hit[1]
      if (state[h][w]==:unknown)
        unknowns << [w,h]
      end
    end
    return random_unknown(state) if unknowns.empty?
    unknowns[rand(unknowns.size)]
  end

  def strike_turn(state)
    smart_strike(state)
  end

  def get_ship_points(ship)
    ship_points = []
    ship_size = ship[2]
    orientation = ship[3]
    ship_size.times do |i|
      x = (orientation == :across ? ship[0]+i : ship[0])
      y = (orientation == :down ? ship[1]+i : ship[1])
      ship_points << [x,y]
    end
    ship_points
  end

  #return ship location based on size and on other ship locations
  def set_ship(ship)
    orientation = ((rand()>0.5)? :across : :down)
    x_range = (orientation == :across ? @width-ship : @width)
    y_range = (orientation == :down ? @height-ship : @height)
    new_ship = []
    valid = false
    while !valid
      valid = true
      new_ship=[rand(x_range), rand(y_range), ship, orientation]
      get_ship_points(new_ship).each { |xy| valid = false if @occupied[xy] }
    end
    #found new ship, add position to occupied
    get_ship_points(new_ship).each { |xy| @occupied[xy]=true }
    new_ship
  end

  def clamp value
    [0, [value, 9].min].max
  end

  def valid? move, state
    x=move[0]
    y=move[1]
    return false if (x< 0 || x > @width-1)
    return false if (y <0 || y > @height-1)
    return false if (state[y][x]!= :unknown)
    return true
  end


end
