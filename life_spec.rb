require 'rspec'
require_relative 'life'

rand_box_gen =-> dead_or_alive, num_neighbors {
  grid      = [[0, 0, 0], [0, dead_or_alive, 0], [0, 0, 0]] # all dead
  grid_size = 3
  while num_neighbors > 0 do
    get_rand =-> { (0...grid_size).to_a.sample }
    i, j     = get_rand.call, get_rand[]
    next if (i==1 and j==1)
    if (grid[i][j] == 0) and (rand > 0.5)
      grid[i][j]   = 1
      num_neighbors-=1
    end
  end
  grid
}

describe 'Lets Test the Game.. the Game of Life' do
  let(:default_life) { Life.new }
  let(:test_box_life) { Life.new [3, 3], [1, 0] }
  let(:test_board_life) { Life.new [6, 6], [1, 0] }
  context "error throw checks" do
    # subject { Cell.new(world) }
    it "check Life starts with default values" do
      raise unless default_life.cols == 8
      raise unless default_life.rows == 6
      raise unless default_life.live == 'o'
      raise unless default_life.dead == '-'
    end

    it "board being initialized properly" do
      # todo: need to think of a better scenario
      default_life.init [[0, 1, 1, 0], [1, 0, 1], [0, 0, 0, 1]]
      raise unless default_life.life_grid == [["-", "o", "o", "-", "-", "-", "-", "-"], ["o", "-", "o", "-", "-", "-", "-", "-"], ["-", "-", "-", "o", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-"]]
    end

  end

  context "error throw checks" do
    it "throws UnInitedState Error when initial state has not been inited yet" do
      rescued = false
      begin
        test_box_life.show
      rescue Life::UnInitedState
        # if this passes, it means RuntimeError is thrown properly
        rescued = true
      end
      raise "Not throwing any UnInitedState!" unless rescued
    end

    it "throws OutOfBounds Error when input is out of bounds of the game board" do
      rescued = false
      begin
        test_box_life.instance_eval { create_game_board [[0, 1, 1, 0, 1, 1], [1, 0, 1]] }
      rescue Life::OutOfBounds
        # if this passes, it means RuntimeError is thrown properly
        rescued = true
      end
      raise "Not throwing any RuntimeError!" unless rescued
    end

    it "throws UnexpectedInput Error when @dead and @live values are not as expected" do
      8.times { |i|
        rescued = false
        (0..255).to_a.sample.chr
        box = rand_box_gen[1, i]
        begin
          default_life.instance_eval { check_life_of_cell 1, 1, box }
        rescue Life::UnexpectedInput
          # if this passes, it means UnexpectedInput is thrown properly
          rescued = true
        end
        raise "Not throwing any UnInitedState! for #{i}" unless rescued
      }
    end
  end


  context "Play Test" do
    it 'transitions to the next state for the sample test' do
      sample_start_state = {
          # todo: test these later..
          # :block   => [[[0, 1, 1], [0, 1, 1]]],
          # :boat    => [[[1, 1, 0], [1, 0, 1], [0, 1]]]
          # :beacon => [[[1, 1], [1, 1], [0, 0, 1, 1]], [[0, 0, 1, 1], [1, 1, 1], [0, 0, 0]]],
          :blinker => [[[0, 1, 0], [0, 1, 0], [0, 1, 0]], [[0, 0, 0], [1, 1, 1], [0, 0, 0]]]
      }
      sample_start_state.each { |named_pattern, sequence_of_states|
        total_states                         = sequence_of_states.size
        rand_start_state                     = (0...total_states).to_a.sample
        next_to_rand_state                   = rand_start_state + 1
        next_to_rand_state, rand_start_state = 1, 1 if total_states == 1
        init_state = test_board_life.instance_eval { create_game_board sequence_of_states[rand_start_state] }
        end_state = test_board_life.instance_eval { create_game_board sequence_of_states[next_to_rand_state] }
        result = test_board_life.instance_eval { next_state init_state }
        raise "\nFailing next state check.. for the named pattern #{named_pattern}..
Expected #{end_state}\n Got : #{result}\n" unless result == end_state
      }
    end


  end
  context "Proving Game Laws: Exhaustive Random cell decision checks" do

    it "live cell: all 0 - 8 neighbors check" do
      # Rules 1-3
      # Any live cell with fewer than two live neighbours dies, as if caused by under-population.
      # Any live cell with two or three live neighbours lives on to the next generation.
      # Any live cell with more than three live neighbours dies, as if by over-population.

      live_cases = [2, 3]
      # dead_cases = (0..1).to_a+(4..8).to_a
      8.times { |i|
        box    = rand_box_gen[1, i]
        result = test_box_life.instance_eval { check_life_of_cell 1, 1, box }
        raise "\ncheck for #{i} neighbors fails\ngrid was \n#{box}" unless result == (live_cases.include? i)
      }
    end
    it "dead cell: all 0 - 8 neighbors check" do
      # Ruels 4
      # Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

      live_cases = [3]
      # dead_cases = (0..2).to_a+(4..8).to_a
      8.times { |i|
        box    = rand_box_gen[0, i]
        result = test_box_life.instance_eval { check_life_of_cell 1, 1, box }
        raise "\ncheck for #{i} neighbors fails\ngrid was \n#{box}" unless result == (live_cases.include? i)
      }
    end
  end
end
