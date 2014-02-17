require "bender"

class Bender5Player
  def initialize
    @game = Bender::Game.new(strategies, disable_stats: 10)
  end

  def name
    "Bender Bending Rodríguez 5"
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
      "StatBonus"     => 1,
      "HistoryBonus"  => 1
    }
  end
end
