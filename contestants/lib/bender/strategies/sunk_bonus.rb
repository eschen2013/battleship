module Bender
  module Strategies
    class SunkBonus < Base
      def score
        board.sunk.each do |hit|
          hit.adjacent.each{ |coord| coord.add 1 }
        end
      end
    end
  end
end
