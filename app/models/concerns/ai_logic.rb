module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    next_move = Game.similar_games(best_move_signature)
                    .order('Random()')
                    .last.moves[moves.count] if best_move_signature.present?

    patterned_games = similar_pattern_games if next_move.blank?
    next_move = patterned_games.first.moves[moves.count] if patterned_games.present? && next_move.blank?
    next_move = non_loss_move if next_move.blank?
    next_move = random_move if next_move.blank?

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def best_move_signature
    moves.reload
    signatures = pieces.where(color: current_turn).map do |piece|
      piece.valid_moves.map do |valid_move|
        "#{move_signature} #{piece.startIndex}:#{valid_move}"
      end
    end.flatten

    best_signature = signatures.max_by do |signature|
      Game.similar_games(signature).winning_games(current_turn).count
    end

    if Game.similar_games(best_signature).winning_games(current_turn).count < 1
      best_signature = nil
    end

    best_signature
  end

  def random_move
    ai_piece = pieces.where(color: current_turn)
                     .shuffle.detect { |piece| piece.valid_moves.present? }

    Move.new(
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    )
  end

  def similar_pattern_games
    games = Game.winning_games(current_turn)
    current_signature = move_signature.to_s.split(' ')

    count = (current_signature.count * 0.7).round

    count.times do
      move = current_signature.pop
      games = games.where('move_signature LIKE ?', "%#{move}%")
    end

    games
  end

  def non_loss_move
    piece_with_moves = piece_with_valid_moves(find_bad_moves)

    if piece_with_moves.present? && piece_with_moves.keys.first.present?
      game_piece = piece_with_moves.keys.first

      Move.new(
        currentPosition: piece_with_moves[game_piece].sample,
        startIndex: game_piece.startIndex,
        pieceType: game_piece.pieceType
      )
    end
  end

  def find_bad_moves
    lost_games = Game.similar_games(move_signature)
                     .where(outcome: opponent_color + ' wins')

    lost_games.map do |lost_game|
      bad_move = lost_game.moves[moves.count]
      "#{bad_move.startIndex}:#{bad_move.currentPosition}"
    end.uniq
  end

  def piece_with_valid_moves(bad_moves = [], count = 0)
    moves.reload
    game_piece = pieces.where(color: current_turn).order('RANDOM()').first
    game_moves = filter_bad_moves(game_piece, bad_moves)

    count += 1
    if game_piece.valid_moves.present? && game_moves.present?
      { game_piece => game_moves }
    elsif count < 10
      piece_with_valid_moves(bad_moves, count)
    end
  end

  def filter_bad_moves(game_piece, bad_moves)
    game_piece.valid_moves.reject { |move| bad_moves.include?(move) }
  end

  def opponent_color
    reload.current_turn == 'white' ? 'black' : 'white'
  end
end
