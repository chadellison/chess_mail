class TrainingGame < ApplicationRecord
  validates_uniqueness_of :moves
end
