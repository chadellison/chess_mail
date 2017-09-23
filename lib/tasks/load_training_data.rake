desc "load_training_data"
task load_training_data: :environment do
  puts 'loading training data'

  15.times do |n|
    File.read("#{Rails.root}/training_data/game_set#{n + 1}.pgn")
        .gsub(/\[.*?\]/, 'game')
        .split('game')
        .reject { |moves| moves == "\r\n" }
        .map do |moves|
          moves.gsub("\r\n", '').gsub('.', '. ').split(' ').reject do |move|
            move.include?('.')
          end.join('-')
        end[1..-1]
        .each do |moves|
          if ['0-1', '1-0', '1/2'].include?(moves[-3..-1])
            outcome = moves[-3..-1]
            TrainingGame.create(
              moves: moves[0..-4],
              outcome: outcome,
              move_count: moves.split('-').count * 2
            )

            puts(outcome)
          end
        end
  end
end
