require "bender"

class Bender6Player
  def initialize
    @game = Bender::Game.new(strategies)
  end

  def name
    "Bender Bending Rodríguez 6"
  end

  def new_game
    @game.placements
  end

  def take_turn(state, ships_remaining)
    @game.update(state, ships_remaining)
    @game.run_scores
    @game.move
  end

  def strategies
    {
      "MissPenalty"   => -100,
      "HitBonus"      =>  300,
      "LineEndings"   => 1000,
      "LongLines"     =>  100,
      "StatBonus"     =>    1
    }
  end
end
