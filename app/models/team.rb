class Team < ActiveRecord::Base
  attr_accessible :bags, :bid, :round_score, :total_score, :tricks_won
end
