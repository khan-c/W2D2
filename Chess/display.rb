require 'colorize'
require_relative 'cursor'
require_relative 'board'

class Display

  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
  end

  def render
    @board.grid.each_with_index do |row, x|
      row.each_with_index do |piece, y|
        if @cursor.cursor_pos == [x, y]
          print "#{piece.symbol} ".colorize(:background => :red)
        else
          print "#{piece.symbol} "
        end
      end
      puts
    end
    puts "-------------------"
  end

  def play_loop
    while true
      system("clear")
      render
      @cursor.get_input
    end
  end

end

if $PROGRAM_NAME == __FILE__
  board = Board.new
  Display.new(board).play_loop
end
