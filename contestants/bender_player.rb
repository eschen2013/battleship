require "bender"

class BenderPlayer
  def initialize
    @game = Bender::Game.new(strategies)
  end

  def name
    "Bender Bending Rodríguez"
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
    %i{
      MissPenalty
      HitBonus
      LineEndings
      HistoryBonus
    }
  end
end
