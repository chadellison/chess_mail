module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    # best_signature = best_move_signature
    # notation = Game.similar_games(best_signature)
    #                .order('Random()').last
    #                .move_signature.split('.')[moves.count] if best_signature.present?

    winning_game = Game.similar_games(move_signature)
                       .winning_games(win_value, current_turn)
                       .order('Random()').last

    notation = winning_game.move_signature.split('.')[moves.count] if winning_game.present?

    next_move = create_move_from_notation(notation, pieces) if notation.present?
    next_move = non_loss_move if next_move.blank?
    next_move = random_move if next_move.blank?

    next_move = update_crossed_pawn(next_move)
    move(next_move)
  end

  def update_crossed_pawn(next_move)

    if [next_move[:pieceType] == 'pawn',
        current_turn == 'white',
        next_move[:currentPosition][1] == '8'].all? ||

       [next_move[:pieceType] == 'pawn',
        current_turn == 'black',
        next_move[:currentPosition][1] == '1'].all?

      next_move[:pieceType] = 'queen'
    end

    next_move
  end

  # def best_move_signature
  #
  #   signatures = pieces.where(color: current_turn).map do |piece|
  #     piece.valid_moves.map do |valid_move|
  #       move_data = {
  #         pieceType: piece.pieceType, currentPosition: valid_move, startIndex: piece.startIndex
  #       }
  #       "#{move_signature}#{create_notation(move_data)}"
  #     end
  #   end.flatten
  #   start_time = Time.now
  #
  #   best_signature = signatures.sort_by do |signature|
  #     Game.similar_games(signature).winning_games(win_value, current_turn).count
  #   end.last(4).sample
  #   end_time = Time.now
  #   puts "first part ****************************** #{end_time - start_time}"
  #
  #   if Game.similar_games(best_signature).winning_games(win_value, current_turn).count < 1
  #     best_signature = nil
  #   end
  #
  #   best_signature
  # end

  def random_move
    ai_piece = pieces.where(color: current_turn)
                     .shuffle.detect { |piece| piece.valid_moves.present? }

    {
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    }
  end

  def non_loss_move
    piece_with_moves = piece_with_valid_moves(find_bad_moves)

    if piece_with_moves.present? && piece_with_moves.keys.first.present?
      game_piece = piece_with_moves.keys.first

      {
        currentPosition: piece_with_moves[game_piece].sample,
        startIndex: game_piece.startIndex,
        pieceType: game_piece.pieceType
      }
    end
  end

  def find_bad_moves
    opponent_win = opponent_color == 'white' ? 1 : -1
    lost_games = Game.similar_games(move_signature).where(outcome: opponent_win)

    lost_games.map do |lost_game|
      notation = lost_game.move_signature.split('.')[moves.count]
      position_from_notation(notation)
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
