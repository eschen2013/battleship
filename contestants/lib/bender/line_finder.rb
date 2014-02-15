module Bender
  class LineFinder
    attr_reader :game, :lines

    def initialize(game)
      @game = game
      @lines = []
    end

    def update
      @hits = game.board.hits
      # game.log "Hits: #{@hits.inspect}"
      build_lines
    end

    def build_lines
      @lines.clear
      @hits.each do |coord|
        @lines << trace_across(coord) if hit?(coord.right) && !hit?(coord.left)
        @lines << trace_down(coord)   if hit?(coord.down)  && !hit?(coord.up)
      end
    end

    def hit?(coord)
      @hits.member?(coord)
    end

    def trace_down(coord)
      bottom = coord.down
      while hit?(bottom.down)
        bottom = bottom.down
      end
      Ship.down(coord, bottom)
    end

    def trace_across(coord)
      right = coord.right
      while hit?(right.right)
        right = right.right
      end
      # game.log "trace across #{coord.inspect}..#{right.inspect}"
      Ship.across(coord, right)
    end

  end
end
