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
    board = Board.new(10, [2], [[5,4,2,:down]])
    board.try([5,4])
    assert_equal :hit, player.position_state([5,4], board.report)
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

  def test_ships_in_position_return_zero_if_not_unknown
    player = MojoPlayer.new
    board = [[:hit, :unknown, :unknown],
             [:unknown, :unknown, :unknown],
             [:unknown, :unknown, :unknown]]
    assert_equal 0, player.ships_in_position([0,0], 2, board)
  end
end

class ProbabilityMapTest < MiniTest::Unit::TestCase
  def setup
    @probmap = ProbabilityMap.new([[:unknown, :unknown, :unknown],
                                   [:unknown, :unknown, :unknown],
                                   [:unknown, :unknown, :unknown]], [3,2])
  end

  def test_can_have_ship_returns_true_down
    assert_equal true, @probmap.can_have_ship([1,0], 3, :down)
  end

  def test_can_have_ship_returns_true_up
    assert_equal true, @probmap.can_have_ship([1,2], 3, :up)
  end

  def test_can_have_ship_returns_true_left
    assert_equal true, @probmap.can_have_ship([2,1], 3, :left)
  end

  def test_can_have_ship_returns_true_right
    assert_equal true, @probmap.can_have_ship([0,1], 3, :right)
  end

  def test_can_have_ship_returns_false_up
    assert_equal false, @probmap.can_have_ship([1,1], 3, :up)
  end

  def test_can_have_ship_returns_false_down
    assert_equal false, @probmap.can_have_ship([1,1], 3, :down)
  end

  def test_can_have_ship_returns_false_left
    assert_equal false, @probmap.can_have_ship([1,1], 3, :left)
  end

  def test_can_have_ship_returns_false_right
    assert_equal false, @probmap.can_have_ship([1,1], 3, :right)
  end
end