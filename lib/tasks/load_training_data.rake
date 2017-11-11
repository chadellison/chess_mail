desc "load_training_data"
task load_all_training_data: :environment do
  23.times do |count|
    parse_file(count + 1)
  end
end

task load_training_data: :environment do
  puts 'loading training data'

  parse_file(ENV["FILE_COUNT"])
end

def parse_file(file_number)
  File.read("#{Rails.root}/training_data/game_set#{file_number}.pgn")
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
    game.human = false
    game.robot = true
    game.move_signature = condensed_moves
    game.training_game = true
    game.save(validate: false)

    game.update_attribute(:outcome, outcome)
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
