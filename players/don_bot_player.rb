require 'battleship/board'

class DonBotPlayer
  def name
    "Don Bot"
  end

  def new_game
    @board_size = 10
    board_is_valid = false
    ships = [5, 4, 3, 3, 2]
    until board_is_valid
      @my_board = ships.map { |length| add_random_ship(length) }
      board_is_valid = validate_board(@my_board,ships)
    end
    @my_board
  end

  def take_turn(state, ships_remaining)
    @state = state
    potentials = get_potentials
    fire_at_random(
      potentials.any? ? potentials : get_types(:unknown)
    )
  end

  private

  def add_random_ship(length)
    orientation = (rand(2) == 0 ? :across : :down)
    x = (orientation == :across ? rand(@board_size-length) : rand(@board_size))
    y = (orientation == :down   ? rand(@board_size-length) : rand(@board_size))
    [x,y,length,orientation]
  end

  def validate_board(passed_board,ships)
    # Piggyback on the board class to gank validation functions
    board = Battleship::Board.new(@board_size,ships,passed_board)
    ep = board.send("expand_positions",passed_board)
    board_is_valid = board.send("valid_layout?",ep)
  end

  def fire_at_random(collection)
    collection[rand(collection.size)]
  end

  def get_types(type)
    matches = []
    @state.each_with_index { |column,xi|
      column.each_with_index { |value,yi|
        matches << [yi,xi] if value == type
      }
    }
    matches
  end

  def get_potentials
    potentials_to_return = []
    get_types(:hit).each { |hit|
      unknown_adjacents(hit[0],hit[1]).each { |adjacent|
        potentials_to_return << adjacent
      }
    }
    potentials_to_return.uniq
  end

  def unknown_adjacents(y,x)
    adjacents = [[y-1,x],[y+1,x],[y,x+1],[y,x-1]]
    adjacents.reject! { |a| a[0] < 0 || a[1] < 0 || a[0] >= @board_size || a[1] >= @board_size }
    adjacents.select { |a| @state[a[1]][a[0]] == :unknown }
  end
end

