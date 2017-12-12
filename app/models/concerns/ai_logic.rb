module AiLogic
  extend ActiveSupport::Concern

  def ai_move
    winning_game = random_winning_game
    notation = winning_game.move_signature.split('.')[moves.count] if winning_game.present?
    next_move = create_move_from_notation(notation, pieces) if notation.present?
    next_move = create_from_move_rank(position_signature) if next_move.blank?
    next_move = random_move if next_move.blank?

    next_move = update_crossed_pawn(next_move)
    move(next_move)
  end

  def create_from_move_rank(position_signature)
    move_rank = MoveRank.find_by(position_signature: position_signature)
    return nil if move_rank.blank?

    if current_turn == 'white'
      setup = move_rank.next_positions.where('value > ?', 0).order('value DESC').first
    else
      setup = move_rank.next_positions.where('value < ?', 0).order('value').first
    end

    count = rand(10)
    setup = move_rank.next_positions.where(value: 0).order('RANDOM()').first if setup.blank? && count < 8
    setup.move_data(move_rank.position_signature) if setup.present?
  end

  def update_crossed_pawn(next_move)
    if next_move[:pieceType] == 'pawn' && '18'.include?(next_move[:currentPosition][1])
      next_move[:pieceType] = 'queen'
    end

    next_move
  end

  def random_winning_game
    Game.similar_games(move_signature)
        .winning_games(win_value, current_turn)
        .order('Random()').last
  end

  def random_move
    ai_piece = pieces.where(color: current_turn).order('RANDOM()')
                     .detect { |piece| piece.valid_moves.present? }
    {
      currentPosition: ai_piece.valid_moves.sample,
      startIndex: ai_piece.startIndex,
      pieceType: ai_piece.pieceType
    }
  end

  def opponent_color
    reload.current_turn == 'white' ? 'black' : 'white'
  end
end
