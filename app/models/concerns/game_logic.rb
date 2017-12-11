module GameLogic
  extend ActiveSupport::Concern

  def handle_move(move_params, user)
    move(move_params)

    if checkmate? || stalemate?
      game_outcome = 'draw' if stalemate?
      game_outcome = opponent_color + ' wins' if checkmate?
      handle_outcome(game_outcome)
    elsif robot.blank?
      send_new_move_email(move_params[:currentPosition], move_params[:pieceType], user)
    else
      ai_move
    end
  end

  def current_turn
    move_signature.to_s.split('.').count.even? ? 'white' : 'black'
  end

  def win_value
    current_turn == 'white' ? 1 : -1
  end

  def move(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    if piece.valid_moves.include?(move_params[:currentPosition]) && valid_piece_type?(move_params)
      move_params[:hasMoved] = true
      move_params[:notation] = create_notation(move_params) unless move_params[:notation].present?
      update_board(move_params, piece)
      update_signatures(move_params)
      move_params[:movedTwo] = piece.movedTwo
      move_params[:color] = piece.color
      move_ranks.find_or_create_by(position_signature: position_signature)
      moves.create(move_params)
      piece
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def update_signatures(move_params)
    position_signature = pieces.order(:startIndex)
      .map do |piece|
        "#{piece.startIndex}:#{piece.currentPosition}"
      end.join('.')

    update_columns(
      move_signature: "#{move_signature}#{move_params[:notation]}",
      position_signature: position_signature
    )
  end

  def update_board(move_params, piece)
    piece.handle_moved_two(move_params[:currentPosition])
    handle_castle(move_params, piece) if piece.pieceType == 'king'
    handle_captured_piece(move_params, piece)
    piece.update(move_params)
  end

  def crossed_pawn?(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    piece.pieceType == 'pawn' &&
      piece.color == 'white' && move_params[:currentPosition][1] == '8' ||
      piece.color == 'black' && move_params[:currentPosition][1] == '1'
  end

  def checkmate?
    no_valid_moves? &&
      !pieces.find_by(color: current_turn)
             .king_is_safe?(current_turn, pieces.reload)
  end

  def stalemate?
    [
      only_knight_or_bishop?,
      no_valid_moves? && pieces.find_by(color: current_turn).king_is_safe?(current_turn, pieces.reload),
      moves.count > 9 && moves.last(8).map { |move| move.startIndex.to_s + move.currentPosition }.uniq.count < 5,
    ].any?
  end

  def only_knight_or_bishop?
    black_pieces = pieces.where(color: 'black').pluck(:pieceType)
    white_pieces = pieces.where(color: 'white').pluck(:pieceType)

    [black_pieces, white_pieces].all? do |pieces_left|
      pieces_left.count == 2 &&
        (pieces_left.include?('knight') || pieces_left.include?('bishop'))
    end
  end

  def no_valid_moves?
    pieces.where(color: current_turn).all? do |piece|
      piece.valid_moves.blank?
    end
  end

  def valid_piece_type?(move_params)
    move_params[:pieceType] == pieces.find_by(startIndex: move_params[:startIndex]).pieceType ||
      crossed_pawn?(move_params)
  end

  def handle_castle(move_params, piece)
    column_difference = piece.currentPosition[0].ord - move_params[:currentPosition][0].ord
    row = piece.color == 'white' ? '1' : '8'

    if column_difference == -2
      pieces.find_by(currentPosition: ('h' + row)).update(currentPosition: ('f' + row))
    end

    if column_difference == 2
      pieces.find_by(currentPosition: ('a' + row)).update(currentPosition: ('d' + row))
    end
  end

  def handle_captured_piece(move_params, piece)
    captured_piece = pieces.find_by(currentPosition: move_params[:currentPosition])
    if en_passant?(move_params[:currentPosition], piece)
      captured_piece = handle_en_passant(move_params, piece)
    end

    captured_piece.destroy if captured_piece.present?
  end

  def handle_en_passant(move_params, piece)
    captured_position = move_params[:currentPosition][0] + piece.currentPosition[1]
    captured_piece = pieces.find_by(currentPosition: captured_position)
  end

  def en_passant?(position, piece)
    [
      piece.pieceType == 'pawn',
      piece.currentPosition[0] != position[0],
      pieces.find_by(currentPosition: position).blank?
    ].all?
  end

  def handle_outcome(game_outcome)
    update(outcome: { 'white wins' => 1, 'black wins' => -1, 'draw' => 0 }[game_outcome])
    move_ranks.each do |move_rank|
      move_rank.update(value: move_rank.value + outcome)
    end
  end
end
