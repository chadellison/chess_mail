class PieceSerializer
  class << self
    def serialize(piece)
      {
        type: 'piece',
        id: piece.id,
        attributes: {
          color: piece.color,
          currentPosition: piece.currentPosition,
          pieceType: piece.pieceType,
          startIndex: piece.startIndex,
          movedTwo: piece.movedTwo,
          hasMoved: piece.hasMoved,
          notation: piece.notation
        }
      }
    end
  end
end
