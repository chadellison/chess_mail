module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    games = Game.similar_games(move_signature)
    winning_games = games.winning_games(current_turn)
    drawn_games = games.drawn_games unless winning_games.present?
    non_loss = non_loss_move(games) unless winning_games.present? || drawn_games.present?

    next_move = winning_games.all.sample.moves[moves.count] if winning_games.present?
    next_move = drawn_games.all.sample.moves[moves.count] if drawn_games.present?
    next_move = non_loss if non_loss.present?
    next_move = random_move unless next_move.present?

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def random_move
    ai_piece = piece_with_valid_moves.keys.first

    Move.new(
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    )
  end

  def non_loss_move(games)
    return false if games.blank?
    bad_moves = games.where.not(outcome: current_turn + ' wins').map do |lost_game|
      bad_move = lost_game.moves[moves.count]
      "#{bad_move.startIndex}:#{bad_move.currentPosition}"
    end

    count = 0
    piece_with_moves = piece_with_valid_moves(bad_moves, count)

    game_piece = piece_with_moves.keys.first if piece_with_moves.present?

    if game_piece.present?
      Move.new(
        currentPosition: piece_with_moves[game_piece].sample,
        startIndex: game_piece.startIndex,
        pieceType: game_piece.pieceType
      )
    end
  end

  def piece_with_valid_moves(bad_moves, count)
    game_piece = pieces.reload.where(color: current_turn).order("RANDOM()").first

    game_moves = game_piece.valid_moves.reject do |move|
      bad_moves.include?("#{game_piece.startIndex}:#{move}")
    end

    count += 1
    if game_piece.valid_moves.present? && game_moves.present?
      { game_piece => game_moves }
    else
      if count > 10
        false
      else
        piece_with_valid_moves(bad_moves, count)
      end
    end
  end
end
