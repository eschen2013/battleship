require "minitest/autorun"
require "battleship/board"
require_relative "../players/mojo_player"

class MojoPlayerTest < MiniTest::Unit::TestCase
  include Battleship

  def test_player_should_return_name
    player = MojoPlayer.new
    assert player.name.length > 1
  end

  def test_new_game_returns_array
    player = MojoPlayer.new
    assert player.new_game.class == Array
  end

  def test_new_game_returns_valid_board
    player = MojoPlayer.new
    board = Board.new(10, [5,4,3,3,2], player.new_game)
    assert board.valid?
  end

  def test_take_turn_returns_valid_shot
    player = MojoPlayer.new
    board = Board.new(10, [5,4,3,3,2], player.new_game)
    refute_equal :invalid, board.try(player.take_turn(board.report, board.ships_remaining))
  end

  def test_position_state_returns_hit
    player = MojoPlayer.new
    board = Board.new(10, [2], [[5,5,2,:down]])
    board.try([5,5])
    assert_equal :hit, player.position_state([5,5], board.report)
  end

  def test_position_state_returns_miss
    player = MojoPlayer.new
    board = Board.new(10, [2], [[5,5,2,:down]])
    board.try([1,1])
    assert_equal :miss, player.position_state([1,1], board.report)
  end

  def test_position_state_returns_unknown
    player = MojoPlayer.new
    board = Board.new(10, [2], [[5,5,2,:down]])
    assert_equal :unknown, player.position_state([1,1], board.report)
  end

  def test_next_mode_returns_hunt_first_time
    player = MojoPlayer.new
    board = Board.new(10, [5,4,3,3,2], player.new_game)
    assert_equal :hunt, player.next_mode(board.report, board.ships_remaining)
  end
end