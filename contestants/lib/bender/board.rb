module Bender
  class Board
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def update(state)
      @coords = {}
      state.each_with_index do |row, y|
        row.each_with_index do |status, x|
          @coords[ [x, y] ] = Coord.new(game, x, y, status)
        end
      end
    end

    def at(x, y)
      @coords[ [x, y] ]
    end

    def misses
      all.select(&:miss?)
    end

    def all
      @coords.values
    end
  end
end
