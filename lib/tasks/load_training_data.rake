desc "load_training_data"
task load_training_data: :environment do
  puts 'loading training data'

  File.read("#{Rails.root}/training_data/game_set#{ENV["FILE_COUNT"]}.pgn")
      .gsub(/\[.*?\]/, 'game')
      .split('game')
      .map { |moves| moves.gsub("\r\n", ' ') }
      .reject(&:blank?)
      .map { |moves| make_substitutions(moves) }[1..-1]
      .each { |moves| create_training_game(moves) }
end

def make_substitutions(moves)
  moves.gsub(/[\r\n+]/, '').gsub(/\{.*?\}/, '').gsub('.', '. ').split(' ')
       .reject { |move| move.include?('.') }.join('.')
end

def create_training_game(moves)
  if ['0-1', '1-0', '1/2'].include?(moves[-3..-1])
    result = moves[-3..-1]
    condensed_moves = result == '1/2' ? moves[0..-8] : moves[0..-4]

    outcome = find_outcome(result)

    puts "\n*****************************************************"
    puts condensed_moves

    game = Game.new
    game.save(validate: false)
    game.update_attribute(:human, false)

    start_time = Time.now

    condensed_moves.split('.').each do |notation|
      game.create_move_from_notation(notation, game.pieces.reload)
    end

    game.update_attribute(:outcome, outcome)

    end_time = Time.now

    puts "Duration for game: #{end_time - start_time}"
    puts(outcome)
  end

end

def find_outcome(result)
  case result
  when '0-1'
    'black wins'
  when '1-0'
    'white wins'
  else
    'draw'
  end
end
