require 'colorize'
require_relative 'cursor'
require_relative 'board'

class Display

  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
    @start_pos = nil
  end

  def render
    @board.grid.each_with_index do |row, x|
      row.each_with_index do |piece, y|
        if @cursor.cursor_pos == [x, y]
          print "#{piece.symbol} ".colorize(color: :light_blue, background: :red)
        elsif x.even? && y.even? || x.odd? && y.odd?
          print "#{piece.symbol} ".colorize(color: :light_blue, background: :white)
        else
          print "#{piece.symbol} ".colorize(color: :light_blue)
        end
      end
      puts
    end
    puts "-------------------"
  end

  def play_loop
    until @board.checkmate?(:white) || @board.checkmate?(:black)
      system("clear")
      render
      move = @cursor.get_input
      if move.is_a?(Array)
        if @start_pos
          @end_pos = move
          @board.move_piece(@start_pos, @end_pos)
          @start_pos = nil
        else
          @start_pos = move
        end
      end
    end
  end

  def take_turn

  end

end

if $PROGRAM_NAME == __FILE__
  board = Board.new
  Display.new(board).play_loop
end
