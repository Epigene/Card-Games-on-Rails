class Player < ActiveRecord::Base
  
  attr_accessible :game_id, :user_id, :seat, :total_score
  
  belongs_to :game
  belongs_to :user
  has_many :player_cards
  has_many :cards, :through => :player_cards
  has_many :played_cards, :through => :player_cards
  has_many :player_rounds, :order => "created_at ASC"
  
  validates_presence_of :game_id
  validates_presence_of :seat
  validates_presence_of :total_score
  
  delegate :round_score, :to => :last_player_round
  delegate :hearts_broken, :to => :last_player_round
  delegate :leader, :to => :last_player_round
  delegate :card_passing_set, :to => :last_player_round
  
  def username
    user.try(:username) || "Computer #{seat}"
  end
  
  def hand
    collection = self.reload.player_cards(true).joins("LEFT JOIN played_cards ON played_cards.player_card_id = player_cards.id").where("played_cards.id IS NULL").readonly(false)
    collection.sort{|a,b| a.hand_order <=> b.hand_order }
  end
  
  def choose_card(lead_suit, is_the_first_trick)
    selection = lead_suit.nil? ? hand.shuffle : hand
    selection.each {|c| return c if c.is_valid?(lead_suit, is_the_first_trick) }
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
  
  def cards_to_pass
    card_passing_set.player_cards
  end
  
  def is_human?
    user.present?
  end
  
  def is_computer?
    !is_human?
  end
  
  def is_game_master?
    seat == 0
  end
  
  def is_a_bystander?
    !is_game_master?
  end
  
  def ready_to_pass?
    cards_to_pass.length == 3 && !card_passing_set.is_ready?
  end
  
  def has_passed?
    card_passing_set.is_ready
  end
  
  def has_not_passed_yet?
    !has_passed?
  end
  
  def relative_seat_of(player)
    seat_shift = (player.seat - self.seat) % 4
    %w(none left top right)[seat_shift]
  end
  
  def seat_position
    %w(none left top right)[seat]
  end
  
end
