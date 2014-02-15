require "bender"

class BenderPlayer
  def name
    "Bender Bending Rodríguez"
  end

  def new_game
    @game = Bender::Game.new
    @game.placements
  end

  def take_turn(state, ships_remaining)
    @game.update(state, ships_remaining)
    @game.run_scores
    @game.move
  end
end
