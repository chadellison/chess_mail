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

    case outcome
    when '0-1'
      outcome = 'black wins'
    when '1-0'
      outcome = 'white wins'
    else
      outcome = 'draw'
    end

    puts '*****************************************************'
    game = Game.create(
      challengedName: Faker::Name.name,
      challengedEmail: Faker::Internet.email,
      challengerColor: 'white'
    )

    start_time = Time.now

    condensed_moves.split('.').each do |notation|
      game.create_move_from_notation(notation, game.pieces.reload)
    end

    game.update(outcome: outcome)

    end_time = Time.now

    puts "Duration for game: #{end_time - start_time}"
    puts(outcome)
  end
end
