require_relative 'piece'

class Board

  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }

    Piece.all_pieces(self).each do |piece|
      self[piece.current_pos] = piece
    end

    null_piece = NullPiece.instance

    @grid.flatten.map do |piece|
      null_piece if piece.nil?
    end
  end

  def move_piece(start_pos, end_pos)
    if self[start_pos].nil?
      raise "No piece at this position."
    elsif !self[end_pos].nil?
      raise "Position occupied."
    else
      self[end_pos] = self[start_pos]
      self[start_pos] = nil
    end
  end

  def []=(pos, value)
    x,y = pos
    @grid[x][y] = value
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def in_bounds?(pos)
    pos.all? {|el| el < 8 && el >= 0}
  end


end
