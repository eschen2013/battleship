class AssmongerPlayer
  def name
    "Assmonger"
  end

  def new_game
      @hit_stack = []
      @prev_ships = []
      @last_shot = nil
      @mode = 0
    [
      [0, 9, 5, :across],
      [9, 0, 4, :down],
      [9, 4, 3, :down],
      [0, 0, 3, :down],
      [1, 0, 2, :across]
    ]

  end

  def take_turn(state, ships_remaining)
    was_a_hit = 0
    if @last_shot and state[@last_shot[1]][@last_shot[0]] == :hit
        was_a_hit = 1
        if @prev_ships != ships_remaining
            @hit_stack = []
            @mode = 0
        else
            @mode = 1
        end
    end
    if @mode == 1 and was_a_hit
        puts "Last shot was %d, %d" % [@last_shot[0], @last_shot[1]]
        if @last_shot[0]-1>=0 and state[@last_shot[1]][@last_shot[0]-1] == :unknown then @hit_stack += [[@last_shot[0]-1, @last_shot[1]]] end
        if @last_shot[0]+1 < 10 and state[@last_shot[1]][@last_shot[0]+1] == :unknown then @hit_stack += [[@last_shot[0]+1, @last_shot[1]]] end
        if @last_shot[1]-1>=0 and state[@last_shot[1]-1][@last_shot[0]] == :unknown then @hit_stack += [[@last_shot[0], @last_shot[1]-1]] end
        if @last_shot[1]+1 < 10 and state[@last_shot[1]+1][@last_shot[0]] == :unknown then @hit_stack += [[@last_shot[0], @last_shot[1]+1]] end

        @hit_stack = @hit_stack.uniq

    end
    if @mode == 1
        @last_shot = @hit_stack.shift
    end
    if @mode == 0 or @last_shot == nil
        selection = []
        for y in 0..9
            for x in 0..9
                if state[y][x] == :unknown
                    selection += [[x, y]]
                end
            end
        end

        hx, hy = selection.sample
        @last_shot = [hx, hy]
    end
    @prev_ships = ships_remaining.dup
    return @last_shot
  end
end
