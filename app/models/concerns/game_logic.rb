module GameLogic
  extend ActiveSupport::Concern

  def handle_move(move_params, user)
    move(move_params)

    if checkmate? || stalemate?
      update(outcome: find_outcome)
    elsif robot.blank?
      send_new_move_email(move_params[:currentPosition], move_params[:pieceType], user)
    else
      ai_move
    end
  end

  def find_outcome
    game_outcome = 'draw' if stalemate?
    opponent_color = current_turn == 'white' ? 'black' : 'white'

    game_outcome = opponent_color if checkmate?
  end

  def move(move_params)
    piece = pieces.find_by(startIndex: move_params[:startIndex])

    if piece.valid_moves.include?(move_params[:currentPosition]) && valid_piece_type?(move_params)
      move_params[:hasMoved] = true
      update_board(move_params, piece)
      create_move(piece)
      update_move_signature(move_params)
      piece
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def create_move(piece)
    move = piece.attributes
    move.delete('id')
    moves.create(move)
  end

  def update_board(move_params, piece)
    piece.handle_moved_two(move_params[:currentPosition]) if piece.pieceType == 'pawn'
    handle_castle(move_params, piece) if piece.pieceType == 'king'
    handle_captured_piece(move_params, piece)
    piece.update(move_params)
  end

  def update_move_signature(move_params)
    updated_signature = "#{move_signature} #{move_params[:startIndex]}" \
                          ":#{move_params[:currentPosition]}"

    update_attribute(:move_signature, updated_signature)
  end

  def crossed_pawn?(move_params)
    color = pieces.find_by(startIndex: move_params[:startIndex]).color

    pieces.find_by(startIndex: move_params[:startIndex]).pieceType == 'pawn' &&
      color == 'white' && move_params[:currentPosition][1] == '8' ||
      color == 'black' && move_params[:currentPosition][1] == '1'
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
      pieces_left.count == 2 && pieces_left.include?('knight') ||
        pieces_left.include?('bishop')
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
end
