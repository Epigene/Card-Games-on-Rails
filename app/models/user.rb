class User < ActiveRecord::Base

  include SimplestAuth::Model
  authenticate_by :username
  
  attr_accessible :username, :password, :password_confirmation
  
  has_many :players, :dependent => :destroy, :order => "created_at ASC"
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_confirmation_of :password, :if => :password_required?

  delegate :hand, :to => :current_player
  
  def current_player
    players.last
  end
  
  def is_already_in(game)
    current_player.present? && current_player.game_id == game.id
  end
  
end
