require "bender"

class Bender2Player
  def initialize
    @game = Bender::Game.new(strategies)
  end

  def name
    "Bender Bending Rodríguez 4"
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
      "MissPenalty"   => -10,
      "HitBonus"      => 30,
      "LineEndings"   => 100,
      "StatBonus"     => 1
    }
  end
end
