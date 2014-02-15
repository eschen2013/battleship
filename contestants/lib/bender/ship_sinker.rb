module Bender
  class ShipSinker
    attr_reader :game, :remaining

    def initialize(game, ships)
      @remaining = ships
      @sunk = []
      @game = game
    end

    def update(remaining)
      sank = find_what_sank(remaining.sort)
      match(sank) if sank
      sink_ships
      @remaining = remaining
    end

    def find_what_sank(current)
      sank = nil
      if @remaining.size != current.size
        @remaining.sort.each_with_index do |size, i|
          if size != current[i]
            sank = size
            break
          end
        end
      end
      sank
    end

    def match(ship_size)
      last_move = game.last
      possible_ships = game.lines.select do |line|
        line.member?(last_move) && line.length == ship_size
      end
      @sunk << possible_ships.first if possible_ships.one?
    end

    def sink_ships
      @sunk.each do |ship|
        ship.points.each do |xy|
          game.board.at(*xy).status = :sunk
        end
      end
    end
  end
end
