class EugmillPlayer
  BLANK_BOARD = [
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
  ]

  ORIENTATIONS = [:across,:down]

  def initialize
    @move_counter = 0
    @history = []
    @ships_last_move = [2,3,3,4,5]
    @hits = [] #coordinates of currently hunted ship
    @sunk_ships = nil #coordinates of sunk ships
    @target_mode = :search
    @sunk = []
  end

  def name
    "Eugmill Player"
  end

  def new_game
    [
      [4, 9, 5, :across],
      [0, 0, 4, :down],
      [0, 9, 3, :across],
      [9, 0, 3, :down],
      [6, 6, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)

    update_hits(state,ships_remaining)
    (@hits.empty?) ? (@target_mode = :search) : (@target_mode = :hunt)
    @move_counter+=1

    pboard = get_probability_board(state, ships_remaining)

    if @target_mode == :search
      moves = get_best_moves(state,ships_remaining,pboard)
      row,col = moves[rand(moves.size)]
      @history.push([row,col])
      [col,row]
    else 
      hit_neighbors = get_hit_neighbors(state)
      pboard = add_hit_weights(pboard,hit_neighbors)
      moves = get_best_moves(state,ships_remaining,pboard)
      row,col = moves[rand(moves.size)]
      @history.push([row,col])
      [col,row]
    end
  end

  def add_hit_weights(board, cells)
    cells.each do |row,col|
      board[row][col] += 50
    end
    board
  end

  def update_hits(state, ships_remaining)
    if (@move_counter > 0)
      if last_turn_hit?(state)
        @hits.push(@history.last)
      end
      if @ships_last_move.size > ships_remaining.size
        sunk_size = sunk_ship_size(ships_remaining)
        update_sunk_ship(get_sunk_ship_coords(sunk_size,state))
      end
      @ships_last_move = ships_remaining
    end

    (0..9).each do |row|
      (0..9).each do |col|
        if(@sunk.include?([row,col]))
          state[row][col] = :sunk
        end
      end
    end
  end

  def get_hit_neighbors(state)
    neighbors = []
    @hits.each do |hit|
      neighbors += (get_valid_neighbors(hit,state))
    end
    neighbors.uniq
  end

  def get_valid_neighbors(cell,state)
    row,col = cell[0],cell[1]
    all_neighbors = get_neighbors(row,col)
    all_neighbors.delete_if {|row,col| row>9 || col>9}
    all_neighbors.delete_if {|row,col| state[row][col] == :miss}
    all_neighbors.delete_if {|row,col| state[row][col] == :sunk}
    all_neighbors.delete_if {|row,col| state[row][col] == :hit}
    all_neighbors.uniq
  end

  def get_neighbors(row,col)
    [[row+1,col],[row-1,col],[row,col+1],[row,col-1]]   
  end

  def update_sunk_ship(coords)
    coords.each do |cell|
      @sunk.push(@hits.delete(cell))
    end
  end

  def last_turn_hit?(state)
    row,col = @history.last
    state[row][col] == :hit
  end

  def last_turn_sink?(ships_remaining)
    @num_ships_left > ships_remaining.size
  end

  def sunk_ship_size(new_list)  
    @ships_last_move.sort.each_with_index do |size,index|
      return size if size != new_list.sort[index]
    end
  end

  def get_sunk_ship_coords(size,state)
     last_row,last_col = @history.last
     @hits.each do |row,col|
      ORIENTATIONS.each do |orientation|
        if is_valid_placement(row, col, orientation,size, state)
          coords = get_coordinates_of_move(row,col,orientation,size)
          if coords.include?([last_row,last_col])
            if coords.all?{|x| @hits.include?(x)}
              return coords
            end
          end
        end
      end
     end
  end

  def get_best_moves(state, ships_remaining,board)
    max_row, max_col = 0,0
    max = 0
    moves = []
    board.each_with_index do |row,ri|
      row.each_with_index do |col,ci|
        if @history.include?([ri,ci])
          next
        end
        if board[ri][ci] == max
          moves.push([ri,ci])
        elsif board[ri][ci] > max
          moves = []
          moves.push([ri,ci])
          max = board[ri][ci]
        end
      end
    end
    moves
  end

  def get_probability_board(state,ships_remaining)
    total_board = deep_copy_board(BLANK_BOARD)
    ships_remaining.each do |ship|
      next_board = ship_probability_board(state,ship)
      total_board = sum_two_boards(total_board, next_board)
    end
    total_board
  end

  def sum_two_boards(board1,board2)
    board1.each_with_index.map do |row,index| 
      [row,board2[index]].transpose.map{|c1,c2| c1+c2}
    end
  end

  def ship_probability_board(state,ship)
    board = deep_copy_board(BLANK_BOARD)
    # board = BLANK_BOARD
    (0..9).each do |row|
      (0..9).each do |col|
        ORIENTATIONS.each do |orientation|
          if(is_valid_placement(row,col,orientation,ship,state))
            get_coordinates_of_move(row,col,orientation,ship).each do |r,c|
              board[r][c] += 1
            end
          end
        end
      end
    end
    board
  end

  def deep_copy_board(board)
    return board.map{|x| x.dup}
  end
  
  def is_valid_placement(x, y, orientation,size, state)
    coordinates = get_coordinates_of_move(x,y,orientation, size)
    return false if !in_bounds?(coordinates)
    return false if includes_misses?(coordinates,state)
    return false if includes_sunk?(coordinates,state)
    true;
  end

  #Coordinates a ship would take up
  def get_coordinates_of_move(row,col,orientation,size)
    return (col...col+size).to_a.map {|i| [row,i]} if orientation == :across
    return (row...row+size).to_a.map {|i| [i,col]} if orientation == :down
  end

  def includes_misses?(coordinates,state)
    coordinates.any? {|xy| state[xy[0]][xy[1]] == :miss }
  end

  def includes_sunk?(coordinates,state)
    coordinates.any? {|xy| state[xy[0]][xy[1]] == :sunk }
  end

  def in_bounds?(coordinates)
    coordinates.all? do |coordinate|
      coordinate[0]<10 && coordinate[1] < 10
    end
  end

  def pprint_board(state, target=nil)
    pretty_string = "\n"
    pretty_string << "   0  1  2  3  4  5  6  7  8  9\n"
    state.each_with_index do |row,ri|
      pretty_string << "#{ri} "
      row.each_with_index do |cell,ci|
        pretty_string << "[#{shorten(cell)}]"
      end
      pretty_string << "\n"
    end
    pretty_string
  end

  def ppprint_board(board)
    pretty_string = "\n"
    pretty_string << "   0  1  2  3  4  5  6  7  8  9\n"
    board.each_with_index do |row,ri|
      pretty_string << "#{ri} "
      row.each_with_index do |cell,ci|
        if cell.to_s.size<2
          pretty_string << (" "<<cell.to_s<<" ")
        else
          pretty_string << (cell.to_s<<" ")
        end
        # pretty_string << "[#{shorten(cell)}]"
      end
      pretty_string << "\n"
    end
    pretty_string
  end

  def shorten(symbol)
    case symbol
    when :unknown 
      ' '
    when :miss 
      'M'
    when :hit 
      'H'
    when :sunk
      'S'
    else 
      symbol
    end
  end
# End helper methods

end
