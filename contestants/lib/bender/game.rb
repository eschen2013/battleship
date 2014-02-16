module Bender
  class Game
    attr_reader :board, :moves, :past
    attr_accessor :strategies

    def initialize(strategies)
      @strategies = strategies
      # @logger = Logger.new("debug.log")
      initial_ships = [5, 4, 3, 3, 2]
      @board = Board.new(self)
      @finder = LineFinder.new(self)
      @sinker = ShipSinker.new(self, initial_ships)
      @placer = ShipPlacer.new(self, initial_ships)
      @past   = PastGames.new(self)
      @moves = []
    end

    def update(state, ships_remaining)
      board.update(state)
      past.whittle board.hits, board.misses
      @sinker.update(ships_remaining)
    end

    def run_scores
      strategies.each do |name|
        Strategies.const_get(name).new(self).score
      end
      # log "Lines:\n#{lines.inspect}\nBoard:\n#{board.inspect}"
    end

    def best_move
      by_score = board.available.sort_by{ |c| c.score * -1 }
      top = by_score.first
      by_score.take_while{ |c| c.score == top.score }.sample
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

    def placements
      @placements ||= @placer.place.map(&:to_a)
    end

    def move
      coord = best_move
      @moves << [coord.x, coord.y]
      # log "Next move: #{coord.inspect}"
      coord.to_a
    end

    def last
      board.at(*moves.last) if moves.any?
    end
  end
end
