desc "load_training_data"
task train_ai: :environment do
  ENV["COUNT"].to_i.times do
    game = Game.new
    game.save(validate: false)

    until game.checkmate? || game.stalemate? || game.moves.count > 250
      game.ai_move
      outcome = 'draw' if game.stalemate?
      outcome = "#{game.current_turn} wins" if game.checkmate?
      puts "#{game.moves.last.pieceType}:#{game.moves.last.currentPosition}"
      puts outcome if outcome.present?
      game.update_attributes(outcome: outcome)
    end
  end
end
