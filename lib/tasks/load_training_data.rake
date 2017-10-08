desc "load_training_data"
task load_training_data: :environment do
  puts 'loading training data'

  16.times do |n|
    File.read("#{Rails.root}/training_data/game_set#{n + 1}.pgn")
        .gsub(/\[.*?\]/, 'game')
        .split('game')
        .map { |moves| moves.gsub("\r\n", ' ') }
        .reject(&:blank?)
        .map { |moves| make_substitutions(moves) }[1..-1]
        .each { |moves| create_training_game(moves) }
  end
end

def make_substitutions(moves)
  moves.gsub(/[\r\n+]/, '').gsub(/\{.*?\}/, '').gsub('.', '. ').split(' ')
       .reject { |move| move.include?('.') }.join('.')
end

def create_training_game(moves)
  if ['0-1', '1-0', '1/2'].include?(moves[-3..-1])
    outcome = moves[-3..-1]
    condensed_moves = outcome == '1/2' ? moves[0..-8] : moves[0..-4]

    training_game = TrainingGame.new(
      moves: condensed_moves,
      outcome: outcome,
      move_count: moves.split('.')
    )

    if training_game.save
      puts training_game.id.to_s + '**********************************'
      game = Game.new

      json_pieces = JSON.parse(File.read(Rails.root + 'json/pieces.json'))

      game.pieces = json_pieces.deep_symbolize_keys.values.map do |json_piece|
        Piece.new(json_piece[:piece])
      end

      start_time = Time.now

      training_game.moves.split('.').each do |move|
        game.pieces = game.create_move_from_notation(move, game.pieces)
      end

      end_time = Time.now

      puts "Duration for game: #{end_time - start_time}"
      puts(training_game.outcome)
    end
  end
end
