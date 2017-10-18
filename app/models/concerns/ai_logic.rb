module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    games = Game.similar_game(move_signature)

    if games.winning_game(current_turn).present?
      next_move = game.winning_game(current_turn).all.sample.moves[moves.count]
    elsif games.drawn_game.present?
      next_move = game.drawn_game.all.sample.moves[moves.count]
    elsif non_loss_move(games).present?
      next_move = non_loss_move(games)
    else
      next_move = random_move
    end

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def random_move
    ai_piece = pieces_with_valid_moves.sample

    Move.new(
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    )
  end

  def non_loss_move(games)
    bad_moves = games.where.not(outcome: current_turn + ' wins').map do |lost_game|
      bad_move = lost_game.moves[moves.count]
      bad_move.startIndex + ':' + bad_move.currentPosition
    end
    potential_moves = pieces_with_valid_moves

    non_losing_moves = potential_moves.reject do |potential_move|
      bad_moves.include?("#{potential_move.startIndex}:#{potential_move.currentPosition}")
    end

    non_losing_moves.sample
  end

  def pieces_with_valid_moves
    pieces.reload.where(color: current_turn).all.reject do |game_piece|
      game_piece.valid_moves.empty?
    end
  end
end
