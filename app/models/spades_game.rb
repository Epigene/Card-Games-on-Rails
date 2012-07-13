class SpadesGame < Game
  
  def play_game
    until(game_over?)
      new_dealer_index = get_dealer_index
      new_round = SpadesRound.create(:game_id => self.id, :dealer_index => new_dealer_index)
      new_round.play_round
      check_for_and_set_winner
      # puts teams.map{|t| [t.total_score]}.inspect
      # self.update_attributes(:winner_id => players.first.id)
    end    
  end

  def check_for_and_set_winner      
    winning_value = 500
    self.teams.each do |team|
      if team.reload.total_score >= winning_value
        winning_value = team.total_score
        self.winner_id = team.id
        self.save
      end
    end
  end

  def reset_scores
    teams.each do |team|
      team.total_score = 0
      team.bid = 0
      team.bags = 0
      team.round_score = 0
      team.total_score = 0
    end
  end

  def set_teams
    if teams.nil?
      team1 = Team.create(:game_id => id)
      team2 = Team.create(:game_id => id)
    else
      team1 = teams.first
      team2 = teams.last
    end
    [0,2].each do |i|
      players[i].team_id = team1.id
      players[i].save
    end
    [1,3].each do |i|
      players[i].team_id = team2.id
      players[i].save
    end 
  end
  
  def winner
    Team.find(winner_id) if winner_id.present?
  end
end