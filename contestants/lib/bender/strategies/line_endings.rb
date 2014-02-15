module Bender
  module Strategies
    class LineEndings < Base
      def score
        longest_remaining = game.ships.remaining.max
        lines.each do |line|
          next unless line.length < longest_remaining
          line.extensions.each do |xy|
            coord = board.at(*xy)
            coord.add(10) if coord && coord.unknown?
          end
        end
      end
    end
  end
end
