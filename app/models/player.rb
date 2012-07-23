class Player < ActiveRecord::Base
  
  attr_accessible :game_id, :user_id, :seat, :total_score
  
  belongs_to :game
  belongs_to :user
  has_many :player_cards
  has_many :cards, :through => :player_cards
  has_many :played_cards, :through => :player_cards
  has_many :player_rounds, :order => "created_at ASC"
  
  validates_presence_of :game_id
  validates_presence_of :user_id
  validates_presence_of :seat
  validates_presence_of :total_score
  
  delegate :username, :to => :user
  delegate :round_score, :to => :last_player_round
  delegate :hearts_broken, :to => :last_player_round
  delegate :leader, :to => :last_player_round
  delegate :card_passing_set, :to => :last_player_round
  
  def hand
    self.reload.player_cards(true).joins("LEFT JOIN played_cards ON played_cards.player_card_id = player_cards.id").where("played_cards.id IS NULL").readonly(false)
  end
  
  def choose_card(lead_suit)
    hand.shuffle.each {|c| return c if c.is_valid?(lead_suit) }
  end

  def has_none_of?(suit)
    self.hand.each do |card|
      return false if card.suit == suit
    end
    true
  end
  
  def only_has?(suit)
    self.hand.each do |card|
      return false if card.suit != suit
    end
    true
  end
  
  def select_random_card
    hand[rand(hand.length)]
  end
  
  def choose_cards_to_pass
    passing_set = last_player_round.card_passing_set
    until(passing_set.cards.length == 3)
      choice = select_random_card
      unless passing_set.cards.include?(choice)
        choice.update_attributes(:card_passing_set_id => passing_set.id)
      end      
    end
  end
  
  def last_player_round
    player_rounds.last
  end
  
  def two_of_clubs
    player_cards.each do |card|
      return card if (card.value == "2" && card.suit == "club")
    end
    nil
  end
  
  def is_leading?
    self == leader
  end
  
  
end
