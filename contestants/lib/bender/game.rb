module Bender
  class Game
    attr_reader :board
    attr_accessor :strategies

    def initialize
      @board = Board.new(self)
      @strategies = [
        Strategies::MissPenalty.new(self)
      ]
      @logger = Logger.new("debug.log")
    end

    def update(state)
      board.update(state)
    end

    def run_scores
      strategies.each(&:score)
    end

    def log(msg)
      @logger.info msg if @logger
    end
  end
end
