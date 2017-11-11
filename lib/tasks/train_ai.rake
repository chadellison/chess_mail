desc "load_training_data"
task train_ai: :environment do
  ENV["COUNT"].to_i.times do
    game = Game.new
    game.human = false
    game.robot = true
    game.save(validate: false)

    initial_start_time = Time.now

    until game.outcome.present? || game.moves.count >= 100
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

    end_time = Time.now
    puts "game time *************** #{end_time - initial_start_time}"
  end
end
