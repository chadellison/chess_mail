class UserSerializer
  class << self
    def serialize(user)
      {
        data: {
          type: 'user',
          id: user.id,
          attributes: {
            hashed_email: user.hashed_email,
            token: user.token,
            firstName: user.firstName,
            lastName: user.lastName
          },
          included: serialized_user_games(user)
        }
      }
    end

    def serialized_user_games(user, page = 1, quantity = 6)
      page = 1 if page.blank?

      archived_game_ids = user.archives.pluck(:game_id)
      user_games = user.games.not_archived(archived_game_ids)
                       .order(created_at: :desc)
                       .offset(calculate_offset(page, quantity))
                       .limit(quantity)

      user_games.map { |user_game| GameSerializer.serialize(user_game, user.email) }
    end

    def calculate_offset(page, quantity)
      (page.to_i - 1) * quantity.to_i
    end
  end
end
