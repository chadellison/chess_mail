module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    # if not checkmate or stalemate
    game = Game.similar_game(move_signature)
    game = game.drawn_game if game.drawn_game.present?
    game = game.winning_game(current_turn) if game.winning_game(current_turn).present?

    next_move = game.all.sample.moves[moves.count] if game.present?
    next_move = random_move unless next_move.present?

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def random_move
    ai_piece = pieces.reload.where(color: current_turn).all.reject do |game_piece|
      game_piece.valid_moves.empty?
    end.sample

    Move.new(
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    )
  end
end
