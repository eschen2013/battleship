module Bender
  module Strategies
    class StatBonus < Base
      def initialize(*a)
        super(*a)
        compute_stats
      end

      def compute_stats
        @stats = Hash.new(0)
        games = Bender.game_history.map do |game|
          game.map{ |ship| Ship.new(*ship) }
        end
        games.each do |ships|
          ships.each do |ship|
            ship.points.each do |xy|
              @stats[xy] += weight
            end
          end
        end
      end

      def score
        @stats.each_pair do |xy, score|
          board.at(*xy).add(score)
        end
      end

    end
  end
end
