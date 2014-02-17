module Bender
  module Strategies
    class StatBonus < Base

      def score
        Bender.game_stats.each_pair do |xy, score|
          board.at(*xy).add(score)
        end
      end

    end
  end
end
