require "bender"

class Bender2Player
  def initialize
    @game = Bender::Game.new(strategies, extended_history: false)
  end

  def name
    "Bender Bending Rodríguez 2"
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
      "MissPenalty"   => -1,
      "HitBonus"      => 3,
      "LineEndings"   => 10,
      "HistoryBonus"  => 1
    }
  end
end
