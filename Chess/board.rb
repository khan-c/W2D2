require_relative 'piece'

class Board

  attr_reader :grid

  def initialize(pieces = Piece.all_pieces(self))
    @grid = Array.new(8) { Array.new(8, NullPiece.instance) }

    pieces.each do |piece|
      self[piece.current_pos] = piece
    end
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    if valid_move?(piece, end_pos)
      if piece == NullPiece.instance
        raise "No piece at this position."
      elsif self[end_pos].side == piece.side
        raise "Position occupied."
      else
        self[end_pos] = piece
        self[end_pos].update_position(end_pos)
        self[start_pos] = NullPiece.instance
      end
    else
      raise "Invalid move"
    end
  end

  def valid_move?(piece, pos)
    piece.moves.include?(pos)
  end

  def []=(pos, value)
    x, y = pos
    @grid[x][y] = value
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def in_bounds?(pos)
    pos.all? { |el| el < 8 && el >= 0 }
  end

  def checkmate?(side)
    if in_check?(side)
      valid_moves = []
      opposing_pieces(Piece.opposite_side(side)).each do |piece|
        valid_moves += piece.valid_moves
      end
      valid_moves.empty?
    end

    false
  end

  def in_check?(side)
    moves = []

    opposing_pieces(side).each do |piece|
      moves += piece.moves
    end

    moves.include?(find_king(side).current_pos)
  end

  def opposing_pieces(side) #white
    opposing_pieces = []
    @grid.each do |row|
      row.each do |piece|
        opposing_pieces << piece if !piece.is_a?(NullPiece) && piece.side != side
      end
    end

    opposing_pieces
  end

  def find_king(side)
    @grid.each do |row|
      row.each do |piece|
        return piece if (piece.symbol == "\u265A" || piece.symbol == "\u2654") && piece.side == side
      end
    end
  end

  def dup_board
    duped_pieces = []
    @grid.each do |row|
      row.each do |piece|
        duped_pieces << piece.dup unless piece.is_a?(NullPiece)
      end
    end

    duped_pieces.each do |piece|
      piece.current_pos = piece.current_pos.dup
    end

    new_board = Board.new(duped_pieces)
    new_board
  end

end
