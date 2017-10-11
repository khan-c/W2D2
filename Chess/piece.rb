require 'singleton'

module Stepable
  def moves
    moves = []

    move_diffs.each do |diff|
      moves << move(diff)
    end

    moves.compact
  end

  def move(diff)
    row, col = @current_pos[0] + diff[0], @current_pos[1] + diff[1]
    temp_pos = [row, col]
    if !@board.in_bounds?(temp_pos)
      nil
    elsif @board[temp_pos].symbol == NullPiece.instance.symbol
      temp_pos
    elsif @board[temp_pos].side == Piece.opposite_side(self.side)
      temp_pos
    end
  end

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
    # require 'byebug'
    # debugger
    row, col = @current_pos[0] + relative_move[0], @current_pos[1] + relative_move[1]
    temp_pos = [row, col]
    until !@board.in_bounds?(temp_pos)
      if @board[temp_pos].side == self.side
        break
      elsif @board[temp_pos].side == Piece.opposite_side(self.side)
        moves << temp_pos
        break
      else
        moves << temp_pos
        temp_pos = [temp_pos[0] + relative_move[0], temp_pos[1] + relative_move[1]]
      end
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

  attr_reader :symbol, :side
  attr_accessor :current_pos

  def initialize(start_pos, board, symbol = " ", side = :white)
    @current_pos = start_pos
    @board = board
    @symbol = symbol
    @side = side
  end

  def self.opposite_side(side)
    side == :white ? :black : :white
  end

  def update_position(pos)
    @current_pos = pos
  end

  def update_board(board)
    @board = board
  end

  def valid_moves
    moves.reject { |move| move_into_check?(move) }
  end

  def move_into_check?(end_pos)
    duped_board = @board.dup_board
    duped_board.move_piece(self.current_pos, end_pos)
    duped_board.in_check?(self.side)
  end

end

class King < Piece
  include Stepable

  def move_diffs
    [
      [-1, -1], [0, -1], [1, -1], [1, 0],
      [1, 1], [0, 1], [-1, 1], [-1, 0]
    ]
  end
end

class Knight < Piece
  include Stepable

  def move_diffs
    [
      [2, 1], [2, -1], [-2, 1], [-2, -1],
      [1, 2], [1, -2], [-1, 2], [-1, -2]
    ]
  end
end

class Pawn < Piece

  def moves
    row, col = @current_pos
    moves = []
    if @board[[row + forward_dir, col]].is_a?(NullPiece)
      moves += [[row + forward_dir, col]]
      if at_start_row? && @board[[row + 2*forward_dir, col]].is_a?(NullPiece)
        moves += [[row + 2*forward_dir, col]]
      end
    end
    moves += side_attacks
    moves
  end

  def at_start_row?
    if @side == :white
      return @current_pos[0] == 6
    else
      return @current_pos[0] == 1
    end
  end

  def forward_dir
    if @side == :white
      return -1
    else
      return 1
    end
  end

  def side_attacks
    row, col = @current_pos
    [[row + forward_dir, col + 1], [row + forward_dir, col -1]].select do |pos|
      if @board.in_bounds?(pos)
        @board[pos].side == Piece.opposite_side(self.side)
      end
    end
  end

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
