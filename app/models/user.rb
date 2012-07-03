class User < ActiveRecord::Base
  
  attr_accessible :bid, :going_blind, :going_nil, :round_score, :team_id, :total_score, :username, :room_id
  
  belongs_to :team #sometimes
  belongs_to :room #sometimes as well
  
  validates_presence_of :username
    
end
