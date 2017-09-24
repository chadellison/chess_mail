desc "load_training_data"
task load_training_data: :environment do
  puts 'loading training data'

  16.times do |n|
    File.read("#{Rails.root}/training_data/game_set#{n + 1}.pgn")
        .gsub(/\[.*?\]/, 'game')
        .split('game')
        .reject { |moves| moves == "\r\n" }
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

    TrainingGame.create(
      moves: condensed_moves,
      outcome: outcome,
      move_count: moves.split('.').count * 2
    )

    puts(outcome)
  end
end
