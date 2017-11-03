module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    start_time = Time.now
    signatures = pieces.where(color: current_turn).map do |piece|
      piece.valid_moves.map do |valid_move|
        "#{move_signature} #{piece.startIndex}:#{valid_move}"
      end
    end.flatten
end_time = Time.now

puts "******* get signatures ********* #{end_time - start_time}"

    start_time = Time.now
    best_move_signature = signatures.select do |signature|
      calculate_win_ratio(signature) > 1
    end.max_by { |signature| calculate_win_ratio(signature) }

end_time = Time.now

puts "******* best move signature ********* #{end_time - start_time}"

start_time = Time.now
    non_loss = non_loss_move(Game.similar_games(move_signature)) unless best_move_signature.present?
    end_time = Time.now

puts "******* non loss time ********* #{end_time - start_time}"
binding.pry if Game.similar_games(best_move_signature).first.nil? && best_move_signature.present?
    next_move = Game.similar_games(best_move_signature).first.moves[moves.count] if best_move_signature.present?
    next_move = non_loss if non_loss.present?
    next_move = random_move unless next_move.present?

    move(
      currentPosition: next_move.currentPosition,
      startIndex: next_move.startIndex,
      pieceType: next_move.pieceType
    )
  end

  def random_move
    ai_piece = pieces.shuffle.detect { |piece| piece.valid_moves.present? }

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

    piece_with_moves = piece_with_valid_moves(bad_moves)

    game_piece = piece_with_moves.keys.first if piece_with_moves.present?

    if game_piece.present?
      Move.new(
        currentPosition: piece_with_moves[game_piece].sample,
        startIndex: game_piece.startIndex,
        pieceType: game_piece.pieceType
      )
    end
  end

  def piece_with_valid_moves(bad_moves = [], count = 0)
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

  def calculate_win_ratio(signature)
    games = Game.similar_games(signature)
    wins = games.winning_games(current_turn).count.to_f
    return 0 if wins == 0

    opponent_color = current_turn == 'white' ? 'black' : 'white'
    losses = games.winning_games(opponent_color).count.to_f
    wins / losses
  end
end
