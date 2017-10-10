require 'singleton'

module Stepable
  def moves; end
end

module Slideable
  def moves
    moves = []

    move_dirs.each do |dir|
      case dir
      when :horizontal
        moves += move([0, 1])
        moves += move([0, -1])

      when :vertical
        moves += move([1, 0])
        moves += move([-1, 0])

      when :diagonal
        moves += move([1, 1])
        moves += move([-1, -1])
        moves += move([1, -1])
        moves += move([-1, 1])
      end
    end

    moves
  end

  def move(relative_move)
    moves = []
    row, col = @current_pos[0] + relative_move[0], @current_pos[1] + relative_move[1]
    temp_pos = [row, col]
    until @board[temp_pos] != NullPiece
      temp_pos = [temp_pos[0] + relative_move[0], temp_pos[1] + relative_move[1]]
      break if !@board.in_bounds?(temp_pos)
      moves << temp_pos
    end
    moves
  end
end

class Piece

  def self.all_pieces(board)
    pieces = [
      Rook.new([0,0], board, "\u265C", :black), Rook.new([0,7], board, "\u265C", :black),
      Rook.new([7,0], board, "\u2656"), Rook.new([7,7], board, "\u2656"),
      Knight.new([0,1], board, "\u265E", :black), Knight.new([0,6], board, "\u265E", :black),
      Knight.new([7,1], board, "\u2658"), Knight.new([7,6], board, "\u2658"),
      Bishop.new([0,2], board, "\u265D", :black), Bishop.new([0,5], board, "\u265D", :black),
      Bishop.new([7,2], board, "\u2657"), Bishop.new([7,5], board, "\u2657"),
      Queen.new([0,3], board, "\u265B", :black), Queen.new([7,3], board, "\u2655"),
      King.new([0,4], board, "\u265A", :black), King.new([7,4], board, "\u2654"),
             ]

    [1, 6].each do |row|
      (0..7).each do |col|
        pieces << Pawn.new([row, col], board, "\u265F", :black) if row == 1
        pieces << Pawn.new([row, col], board, "\u2659") if row == 6
      end
    end

    pieces
  end

  attr_reader :symbol, :current_pos

  def initialize(start_pos, board, symbol = " ", side = :white)
    @current_pos = start_pos
    @board = board
    @symbol = symbol
    @side = side
  end

  def moves
  end
end

class King < Piece

end

class Knight < Piece

end

class Pawn < Piece
end

class Bishop < Piece
  include Slideable

  def move_dirs
    [:diagonal]
  end
end

class Rook < Piece
  include Slideable

  def move_dirs
    [:horizontal, :vertical]
  end
end

class Queen < Piece
  include Slideable

  def move_dirs
    [:diagonal, :horizontal, :vertical]
  end
end

class NullPiece < Piece
  include Singleton

  attr_reader :symbol

  def initialize
    @symbol = " "
  end
end
