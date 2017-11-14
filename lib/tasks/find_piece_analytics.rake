desc 'find_piece_analytics'
task find_piece_analytics: :environment do
  Game.where(outcome: 'white wins', training_game: true).find_each do |game|
    create_position_analytic(game.move_signature, 'white wins')
  end

  Game.where(outcome: 'black wins', training_game: true).find_each do |game|
    create_position_analytic(game.move_signature, 'black wins')
  end

  Game.where(outcome: 'draw', training_game: true).find_each do |game|
    create_position_analytic(game.move_signature, 'draw')
  end
end

def create_position_analytic(signature, outcome)
  signature.split('.').each do |notation|
    game = Game.new

    position_analytic = PositionAnalytic.where(
      position: game.position_from_notation(notation),
      outcome: outcome,
      pieceType: game.piece_type_from_notation(notation)
    ).first_or_create

    position_analytic.space_count += 1
    position_analytic.save
  end
end
