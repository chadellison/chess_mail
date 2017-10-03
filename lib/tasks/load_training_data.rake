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

    training_game = TrainingGame.create(
      moves: condensed_moves,
      outcome: outcome,
      move_count: moves.split('.')
    )

    # game = Game.create(challengedEmail: Faker::Internet.email, challengedName: Faker::Name.name, challengerColor: 'white')
    #
    # outcome = 'black wins' if outcome == '0-1'
    # outcome = 'white wins' if outcome == '1-0'
    # outcome = 'draw' if outcome == '1/2'
    #
    # game.update(outcome: outcome)
    #
    # training_game.moves.split('.').each do |move|
    #   game.create_move_from_notation(move)
    # end
    puts(outcome)
  end
end
