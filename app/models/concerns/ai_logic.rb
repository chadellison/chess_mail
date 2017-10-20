module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    start_time = Time.now
    games = Game.similar_games(move_signature)
    end_time = Time.now
    puts "find similar_games = #{end_time - start_time}"

    start_time = Time.now
    winning_games = games.winning_games(current_turn)
    end_time = Time.now

    puts "find winning_games = #{end_time - start_time}"

    start_time = Time.now
    drawn_games = games.drawn_games unless winning_games.present?
    end_time = Time.now

    puts "find drawn_games = #{end_time - start_time}" unless winning_games.present?

    start_time = Time.now
    non_loss = non_loss_move(games) unless winning_games.present? || drawn_games.present?
    end_time = Time.now

    puts "find non_loss = #{end_time - start_time}" unless winning_games.present? || drawn_games.present?

    next_move = winning_games.all.sample.moves[moves.count] if winning_games.present?
    next_move = drawn_games.all.sample.moves[moves.count] if drawn_games.present?
    next_move = non_loss if non_loss.present?

    start_time = Time.now
    next_move = random_move unless next_move.present?
    end_time = Time.now

    puts "random_move = #{end_time - start_time}" unless winning_games.present? || drawn_games.present? || non_loss.present?

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
    return false if games.blank?

    bad_moves = games.where.not(outcome: current_turn + ' wins').map do |lost_game|
      bad_move = lost_game.moves[moves.count]
      "#{bad_move.startIndex}:#{bad_move.currentPosition}"
    end

    potential_moves = {}
    all_moves = pieces_with_valid_moves

    all_moves.each do |piece|
      move_set = piece.valid_moves.reject do |move|
        bad_moves.include?("#{piece.startIndex}:#{move}")
      end

      potential_moves[piece.startIndex] = move_set if move_set.present?
    end

    startIndex = potential_moves.keys.sample

    if startIndex.present?
      Move.new(
        currentPosition: potential_moves[startIndex].sample,
        startIndex: startIndex,
        pieceType: all_moves.detect { |piece| piece.startIndex == startIndex }.pieceType
      )
    end
  end

  def pieces_with_valid_moves
    pieces.reload.where(color: current_turn).all.reject do |game_piece|
      game_piece.valid_moves.empty?
    end
  end
end
