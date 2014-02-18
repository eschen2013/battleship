$:.unshift File.expand_path("../../data", __FILE__)
require "sample_boards"

class TomBotPlayer

  attr_accessor :state, :last_shot

  def name
    "TomBot"
  end

  def new_game
    Battleship::SAMPLE_BOARDS.sample
  end

  def take_turn(state, ships_remaining)
    unknown_slots.sample
  end

  private

  def unknown_slots
    slots = []
    (0..9).each do |x|
      (0..9).each do |y|
        slots << [x,y] if state[y][x] == :unknown
      end
    end
    slots
  end
end
