class MoveRank < ApplicationRecord
  has_many :move_rank_games
  has_many :games, through: :move_rank_games
  has_many :next_positions, class_name: 'MoveRank', foreign_key: 'next_position_id'

  validates_presence_of :position_signature

  def move_data(previous_signature)
    index_and_move = position_signature.split('.').detect do |position|
      !previous_signature.include?(position)
    end

    create_move_data(index_and_move)
  end

  def create_move_data(index_and_move)
    start_index = index_and_move.split(':').first.to_i
    {
      startIndex: start_index,
      currentPosition:  index_and_move.split(':').last,
      pieceType: Piece.find_by(startIndex: start_index).pieceType
    }
  end

  def add_next_positions(pieces)
    signatures = pieces.map do |piece|
      piece.valid_moves.map do |move|
        position_signature.sub(piece.currentPosition, move)
      end
    end.flatten

    self.next_positions = MoveRank.where(position_signature: signatures)
    save
  end
end
