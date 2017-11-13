class MoveSerializer
  class << self
    def serialize(move)
      {
        type: 'move',
        id: move.id,
        attributes: {
          color: move.color,
          currentPosition: move.currentPosition,
          pieceType: move.pieceType,
          startIndex: move.startIndex,
          movedTwo: move.movedTwo,
          hasMoved: move.hasMoved,
          notation: move.notation
        }
      }
    end
  end
end
