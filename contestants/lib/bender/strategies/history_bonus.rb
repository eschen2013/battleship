module Bender
  module Strategies
    class HistoryBonus < Base

      def score
        remaining = game.past.remaining
        return if remaining.empty?
        total = game.past.total
        weight = total / remaining.count

        remaining.each do |ships|
          ships.each do |ship|
            ship.points.each do |xy|
              coord = board.at(*xy)
              coord.add(weight) if coord && coord.unknown?
            end
          end
        end

      end

    end
  end
end
