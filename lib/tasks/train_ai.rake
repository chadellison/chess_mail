desc "load_training_data"
task train_ai: :environment do
  ENV["COUNT"].to_i.times do
    game = Game.new
    game.save(validate: false)
    game.update_attribute(:human, false)

    until game.checkmate? || game.stalemate? || game.moves.count >= 100
      binding.pry if game.checkmate? || game.stalemate?
      start_time = Time.now
      game.ai_move
      end_time = Time.now
      puts "move time = #{end_time - start_time}"
      outcome = 'draw' if game.stalemate?
      outcome = "#{game.current_turn} wins" if game.checkmate?
      puts "#{game.moves.last.pieceType}:#{game.moves.last.currentPosition}"
      puts outcome if outcome.present?
      game.update_attributes(outcome: outcome) if outcome.present?
    end
  end
end
