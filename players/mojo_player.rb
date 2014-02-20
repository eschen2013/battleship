class MojoPlayer
  def name
    "Mojo Player"
  end

  def new_game
    @history = []
    @prev_ships_remaining = []
    @mode = :hunt

    [
      [1, 1, 5, :across],
      [1, 2, 4, :down],
      [8, 1, 3, :down],
      [1, 8, 3, :across],
      [7, 8, 2, :across]
    ]    
  end

  def take_turn(state, ships_remaining)
    if @history.count < 4
      @history << [rand(10), rand(10)]
    else
      @history << [rand(10), rand(10)]
    end

    @prev_ships_remaining = ships_remaining
    @history.last
  end

  def position_state(position, state)
    state[position[0]][position[1]]
  end

  def ships_in_position(position, ship, state)
    if(position_state(position, state) == :unknown)

    else
      0
    end
  end

  def next_mode(state, ships_remaining)
    :hunt
  end

  def hunt(parity = 2)
    [rand(5) + (@shots.count < 2 ? 0 : 5), rand(5) + (@shots.count % 2 == 0 ? 0 : 5)]
  end
end

class ProbabilityMap
  def initialize(state, ships_remaining)
    #assumes state is a square array. should probably thrown an exception if it isn't...
    @state = state
    @ships_remaining = ships_remaining
  end

  def position_state(position)
    @state[position[0]][position[1]]
  end

  def can_have_ship(position, ship, orientation)
    case orientation
    when :up
      position[0] - ship >= 0 
    when :down
      position[0] + ship - 1 < @state.count
    when :left
      position[1] - ship >= 0
    when :right
      position[1] + ship - 1 < @state.count
    end
  end
end