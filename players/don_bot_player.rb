require 'battleship/board'

class DonBotPlayer
  def name
    "Don Bot"
  end

  def new_game
    board_is_valid = false
    ships = [5, 4, 3, 3, 2]
    until board_is_valid
      @my_board = ships.map { |length| add_random_ship(length) }
      board_is_valid = validate_board(@my_board,ships)
    end
    @my_board
  end

  def take_turn(state, ships_remaining)
    fire_at_random_unknown(state)
  end

  private

  def add_random_ship(length)
    orientation = (rand(2) == 0 ? :across : :down)
    x = (orientation == :across ? rand(10-length) : rand(10))
    y = (orientation == :down   ? rand(10-length) : rand(10))
    [x,y,length,orientation]
  end

  def validate_board(passed_board,ships)
    # Piggyback on the board class to gank validation functions
    board = Battleship::Board.new(10,ships,passed_board)
    ep = board.send("expand_positions",passed_board)
    board_is_valid = board.send("valid_layout?",ep)
  end

  def fire_at_random_unknown(state)
    unknowns = []
    state.each_with_index { |column,xi|
      column.each_with_index { |value,yi|
        unknowns << [yi,xi] if value == :unknown
      }
    }
    unknowns[rand(unknowns.size)]
  end
end

