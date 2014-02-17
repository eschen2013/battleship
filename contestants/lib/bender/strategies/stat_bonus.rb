module Bender
  module Strategies
    class StatBonus < Base
      def initialize(*a)
        super(*a)
        @games = Bender.game_history.map do |game|
          game.map{ |ship| Ship.new(*ship) }
        end
      end

      def score
        @games.each do |ships|
          ships.each do |ship|
            ship.points.each{ |x, y| board.at(x, y).add(weight) }
          end
        end
      end

    end
  end
end
