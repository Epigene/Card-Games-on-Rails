class Trick < ActiveRecord::Base
  
  attr_accessible :lead_suit, :leader_index, :round_id
  
  belongs_to :round
  has_many :played_tricks
  has_many :players, :through => :round
  has_many :decks, :through => :round
  
  def trick_winner
    # best_card = played_trick.cards.last
    best_card = nil
    played_trick.cards.each do |c| 
      if c.was_played_by_id == players[0].id
        best_card = c
      end
    end
    4.times do |i|
      card = played_trick.reload.cards[i]
      best_card = card if card.beats?(best_card)
    end
    User.find(best_card.was_played_by_id)
  end

  def give_trick_to_winner
    played_trick.update_attributes(:user_id => trick_winner.id)
  end

  def store_trick(played_cards)
    new_played_trick = PlayedTrick.create(:size => 4, :trick_id => id)
    played_cards.each do |card|
      card.card_owner_type = "PlayedTrick" 
      card.card_owner_id = new_played_trick.id
      card.save
    end
    played_cards.each do |card|
      if card.reload.card_owner_id.nil?
        card.update_attributes(:card_owner_id => new_played_trick.id)
      end
    end
    raise played_cards.map{|c| [c.reload.card_owner_type, c.reload.card_owner_id]}.inspect if new_played_trick.cards.length != 4
  end

  def trick_winner_index
    players.index(trick_winner)
  end

  # private
  def deck
    decks.last
  end
  
  def leader
    players[leader_index]
  end
  
  def size
    round.game.size
  end
  
  def played_trick
    played_tricks.last
  end
  
  def card_index(card)
    played_trick.cards.index(card)
  end
  
end
