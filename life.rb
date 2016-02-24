# @author Naren Siva Subramani (https://github.com/ufo2mstar)
# @abstract .. because it represents, Life!!
# @deprecated Because there is always a Better Life out there!
## @since 0.0.1 (http://semver.org)
# @see https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
# == Conway's Game of Life
# Haha.. I've been meaning to implement this for a while now!!
# Finally got the chance to :)
# Hopefully we play the Game of Life well..
#   PS: if only Real Life was this simple.. hmm.. maybe..
#   at a molecular, atomic or at least at a quantum level, one might think..
#   But Alas! Virtual Particles prove that wrong too.. :D
# @see https://en.wikipedia.org/wiki/Virtual_particle

class Life
  # @attr cols [Integer] cols of the life grid
  # @attr rows [Integer] rows of the life grid
  # @attr [String] live represents 'live' cells in the life grid
  # @attr [String] dead represents 'dead' cells in the life grid
  attr_accessor :cols, :rows, :live, :dead, :life_grid

  # Begin Life!
  # initializes the size of the grid to play the Game of Life..
  # @param life_size [Array<Integer, Integer>] cols,rows of the 'grid_size' of life.. (dubbed 'life_size' for fun :P )
  # @param alive_dead_symbols [Array<String, String>] way you want to display alive and dead cells.. Strings preferably
  def initialize life_size = [8, 6], alive_dead_symbols = %w[o -]
    @cols, @rows = life_size
    @live, @dead = alive_dead_symbols
    print "Life Size (#{@rows} rows, #{@cols} cols).. ['#{@live}' are alive , '#{@dead}' are dead]"
  end

  # == Error Declarations
  UnInitedState   = Class.new(StandardError)
  OutOfBounds     = Class.new(StandardError)
  UnexpectedInput = Class.new(StandardError)
  RenderError     = Class.new(StandardError) # not used for now..
  # Create Life!!
  # send in arrays of 0's (dead) and 1's (live) of any size
  #   Actions:
  #   {Life#print_state}s the current state of input setup (just for reference)
  #   initializes the @life_grid
  # @note make sure the inputs are within the initialized game board size
  # @param life_grid [Array<Arrays>] input state with 0's representing dead cells and 1's representing alive cells
  def init life_grid
    Log.info 'This is the init setup:'
    print_state life_grid
    @life_grid = create_game_board life_grid
  end

  # Display Life!!
  # the rendering method of the state of the game
  #   Actions:
  #   Clears the previous instant on the screen
  #   Shows the current instant
  def show clear_screen = nil
    raise UnInitedState, 'Please init Life!' unless @life_grid
    # system('clear') if clear_screen
    puts "Showing current state:" unless clear_screen
    print_state @life_grid
  end

  # == Play the Game
  # Call this method from your Life object to run the simulation
  # Actions:
  #   Clears the previous instant on the screen
  #   Shows the current instant
  # @note make sure you have initialized the @life_grid using {Life#init}
  # @param num_of_cycles [Integer] number of game cycles you want to run
  def play! num_of_cycles = 5, sleep_interval = 0.5
    show
    num_of_cycles.times { |i|
      puts "Itr: #{i+1}"
      @life_grid = next_state @life_grid
      show "clear" # todo: figure out a good way to sys clear!
      sleep sleep_interval
    }
    puts "End of game: after #{num_of_cycles} cycles\n\n"
  end

  protected
  # Computes the next state of the World
  # @return [Array<Arrays>] game board with the new state!
  # @param current_state [Array<Arrays>] this is the current 2D grid of the game
  def next_state current_state
    next_state_grid   = []
    compute_cell_life =-> i, j { check_life_of_cell i, j, current_state }
    current_state.each_with_index { |row, i|
      next_state_grid[i]=[]
      row.each_with_index { |col_elem, j|
        next_state_grid[i] << (compute_cell_life[i, j] ? @live : @dead)
      }
    }
    next_state_grid
  end

  private
  # @param current_state [Array<Arrays>] this is the current 2D grid of the game
  # @return [nil] Nil.. just a print method..
  def print_state current_state
    current_state.each { |row| row.each { |col_elem| print "#{col_elem}  " }; puts }
  end

  # This is only called once at the {Life#init} phase..
  # once the board is established and the init conditions are setup,
  # we can just use that board for future transitions
  # @raise [OutOfBounds] if input state is out of bounds of the game_board
  # @param current_state [Array<Arrays>] this is the current 2D grid of the game
  # @return [Array<Arrays>] the game_board with the input conditions..
  def create_game_board input_life_grid
    # creating all dead game board (@rows x @cols)
    game_board = []
    @rows.times { |i| game_board[i] = Array.new @cols, @dead }
    # initializing input state
    input_life_grid.each_with_index { |row, i|
      row.each_with_index { |col_elem, j|
        begin
          raise if i > @rows or j > @cols
          game_board[i][j] = (col_elem == 1 ? @live : @dead)
        rescue Exception => e
          raise OutOfBounds,"\nIs your init condition going out of the bounds?
game_board is only (#{@rows},#{@cols}) large..
you are trying to access (#{i},#{j})"
        end
      }
    }
    game_board
  end

  # Evaluate the new state of the cell based on the Game's (Conway's) Laws!
  # @note the Game Laws are
  #   - Any live cell with fewer than two live neighbours dies, as if caused by under-population.
  #   - Any live cell with two or three live neighbours lives on to the next generation.
  #   - Any live cell with more than three live neighbours dies, as if by over-population.
  #   - Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
  # @raise [UnexpectedInput] if adultrated board is sent.. ie: if the @live and @dead identifiers are not passed in the board
  # @param i [Array<Arrays>] i index of cell in question
  # @param j [Array<Arrays>] j index of cell in question
  # @param grid [Array<Arrays>] the unit box of 3x3 cells with the cell in question at the centre
  # @return [Boolean] true if the cell is Alive, false if Dead!
  def check_life_of_cell i, j, grid
    live_count   = 0
    cell_state   = nil
    offset_range = [-1, 0, 1]
    raise UnexpectedInput, "\nthe Check Grid is to be filled with wither '#{@live}' or '#{@dead}' only..\nbut got #{grid}\n" unless (grid.flatten-[@live, @dead]).empty?
    # calculate live cell count (dead = 8-live)
    offset_range.each { |i_offset|
      offset_range.each { |j_offset|
        (cell_state = grid[i][j]; next) if i_offset == 0 and j_offset == 0
        i_check, j_check = i+i_offset, j+j_offset
        next if [-1, @rows].include? i_check or [-1, @cols].include? j_check
        live_count+=1 if grid[i_check][j_check] == @live
      }
    }

    # Game Laws
    case cell_state
      when @live
        # Any live cell with fewer than two live neighbours dies, as if caused by under-population.
        # Any live cell with two or three live neighbours lives on to the next generation.
        # Any live cell with more than three live neighbours dies, as if by over-population.
        return true if [2, 3].include? live_count
      when @dead
        # Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        return true if [3].include? live_count
      else
        raise "Should never get here"
    end
    false # handles all the 'dies' cases
  end

end

# todo: implement this fully later
# fot setting log levels
class Log
  class << self
    def info *args
      puts args
    end
  end
end

if __FILE__ == $0
#  Main method

# test set
  new_life = Life.new [4, 3], %w[x .]
  new_life.init [[0, 1, 0], [0, 1, 0], [0, 1, 0]]
  new_life.show
  new_life.play!

  # interview problem
  new_life = Life.new [8, 6], %w[o .]
  new_life.init [[0, 0, 0, 0, 0, 0, 1], [1, 1, 1, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1], [], [0, 0, 0, 1, 1], [0, 0, 0, 1, 1]]
  new_life.play! 5, 0.5

  # Conway Glider
  new_life = Life.new [12, 12], %w[# -]
  new_life.init [[1], [0, 1, 1], [1, 1]]
  new_life.play! 16, 0.1

end