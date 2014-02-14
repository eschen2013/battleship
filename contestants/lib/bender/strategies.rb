module Bender
  module Strategies
    class Base
      attr_accessor :game

      def initialize(game)
        self.game = game
      end

      def board
        game.board
      end

      def log(msg)
        game.log(msg)
      end
    end
  end
end
