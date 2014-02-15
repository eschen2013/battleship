module Bender
  class ShipSinker
    attr_reader :game, :remaining

    def initialize(game)
      @remaining = [5, 4, 3, 3, 2]
      @game = game
    end

    def update(remaining)

    end

  end
end
