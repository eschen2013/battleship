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
    @potentials = get_potentials
    @ships_remaining = ships_remaining
    if @potentials.any?
      vectors   = @potentials.select { |p| p[:type] == :vector }
      lone_hits = @potentials.select { |p| p[:type] == :lone_hit }
      smart_targets = vectors.map { |v| follow_vector(v[:adjacent],v[:from_hit]) }.reject { |v| v.nil? }
      if smart_targets.any?
        smart_targets.first.reject(&:nil?)[0]
      elsif lone_hits.any?
        fire_at_random(lone_hits.map{|lh| lh[:adjacent]})
      else
        fire_at_random
      end
    else
      fire_at_random
    end
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

  def fire_at_random(collection=nil)
    collection ||= get_types(:unknown)
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
      this_hit_potentials = []
      all_adjacents = adjacents(hit[0],hit[1])
      hits       = adjacents_by_type(all_adjacents,:hit)
      unknowns   = adjacents_by_type(all_adjacents,:unknown)
      vector_found = false
      unknowns.each { |adjacent|
        if hits.include?(reciprocal_adjacent(hit,adjacent))
          type = :vector
          vector_found = true
        end
        this_hit_potentials << { :adjacent => adjacent, :type => type, :from_hit => hit }
      }
      if vector_found == false && hits.empty?
        this_hit_potentials.each { |thp| thp[:type] = :lone_hit }
      end
      this_hit_potentials.each { |thp| potentials_to_return << thp }
    }
    potentials_to_return.uniq
  end

  def adjacents_by_type(adjacents_array,type)
    adjacents_array.select { |a| @state[a[1]][a[0]] == type }
  end

  def adjacents(y,x)
    [[y-1,x],[y+1,x],[y,x+1],[y,x-1]].reject { |a| !in_bounds(a) }
  end

  def follow_vector(vector,from_hit)
    # A vector is two hits next to each other
    adjacent_hits = adjacents_by_type(adjacents(vector[0],vector[1]),:hit)
    directions = get_vector_directions(adjacent_hits,vector)
    unknowns = grab_unknowns_from_ends(directions,from_hit) || []
    unknowns if unknowns.any?
  end

  def get_vector_directions(adjacent_hits,vector)
    adjacent_hits.map { |hit| (hit[0] == vector[0] ? :column : :row) }
  end

  def reciprocal_adjacent(hit,adjacent)
    # Return the adjacent on the opposite side of the hit
    if adjacent[0] != hit[0]
      [ (adjacent[0] > hit[0] ? hit[0] - 1 : hit[0] + 1), adjacent[1] ]
    else
      [ adjacent[0], (adjacent[1] > hit[1] ? hit[1] - 1 : hit[1] + 1) ]
    end
  end

  def grab_unknowns_from_ends(directions,vector)
    candidates = []
    phase_results = []
    directions.each { |direction|
      if direction == :column
        phase_results = [:up,:down].map { |phase| pointer_phase(phase,vector) }
      else
        phase_results = [:left,:right].map { |phase| pointer_phase(phase,vector) }
      end
      hits_length = phase_results.map { |pr| pr[0] }.inject(:+) - 1
      if hits_length <= @ships_remaining.sort.last && hits_length > 1
        # Hitting the ship is only worth it if the length is less than remaining ships
        candidates << phase_results.reject{ |pr| pr[1].nil? }.map { |pr| pr[1] }[0]
      end
    }
    candidates
  end

  def pointer_phase(phase,vector)
    # Follow the hits until you encounter an unknown, then mark it as a candidate
    pointer = vector.clone
    hit_count = 0

    previous_pointer = pointer.clone
    while in_bounds(pointer) && board_state(previous_pointer) == :hit
      previous_pointer = pointer.clone
      new_state = board_state(pointer)
      if new_state == :unknown
        candidate = pointer.clone
      else
        hit_count += 1 unless new_state == :miss
      end
      pointer = increment_pointer(pointer,phase)
    end
    [hit_count,candidate]
  end

  def increment_pointer(pointer,phase)
    pointer[0] += 1 if phase == :right
    pointer[0] -= 1 if phase == :left
    pointer[1] += 1 if phase == :down
    pointer[1] -= 1 if phase == :up
    pointer
  end

  def in_bounds(coords)
    coords[0] >= 0 && coords[1] >= 0 &&
    coords[0] < @board_size && coords[1] < @board_size
  end

  def board_state(pointer)
    @state[pointer[1]][pointer[0]]
  end
end

