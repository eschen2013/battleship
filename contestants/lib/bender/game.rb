module Bender
  class Game
    attr_reader :board
    attr_accessor :strategies

    def initialize
      @board = Board.new(self)
      @finder = LineFinder.new(self)
      @sinker = ShipSinker.new(self)
      @strategies = [
        Strategies::MissPenalty.new(self),
        Strategies::HitBonus.new(self),
        Strategies::LineEndings.new(self)
      ]
      @logger = Logger.new("debug.log")
    end

    def update(state, ships_remaining)
      board.update(state)
      @sinker.update(ships_remaining)
      @finder.update
    end

    def run_scores
      strategies.each(&:score)
      log("Board:\n#{board.inspect}")
    end

    def log(msg)
      @logger.info msg if @logger
    end

    def lines
      @finder.lines
    end

    def ships
      @sinker
    end
  end
end
