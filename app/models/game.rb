
class Game < ActiveRecord::Base
  
  attr_accessible :winner_id, :name, :session_id

  has_many :players, :dependent => :destroy, :order => "seat ASC"
  has_many :rounds, :dependent => :destroy, :order => "position ASC"
  belongs_to :winner, :class_name => "Player"

  delegate :card_passing_sets, :to => :last_round
  delegate :cards_have_been_passed, :to => :last_round
  
  def add_player_from_user(user)
    if can_accomodate(user)
      Player.create({:user => user, :game => self, :seat => next_seat}, :without_protection => true)
    end
  end
  
  def play_card(card)
    last_trick.play_card_from(next_player, card)
  end

  def create_round
    round = Round.create({:game => self, :dealer_id => get_new_dealer.id, :position => next_round_position}, :without_protection => true)
  end
  
  def get_new_dealer
    rounds_played == 0 ? player_seated_at(0) : next_dealer
  end

  def next_seat
    self.players(true).length
  end

  def next_round_position
    rounds_played
  end

  def is_full?
    players(true).length >= 4
  end

  def is_over?
    winner_id.present?
  end
  
  def is_not_over?
    !is_over?
  end

  def player_seated_at(seat)
    self.players.where("seat = ?", seat).first
  end

  def already_has?(user)
    present_usernames.include?(user.username)
  end

  def last_round
    rounds.last
  end

  def get_lead_suit
    last_trick.try(:lead_suit)
  end

  def is_current_players_turn?(current_player)
    last_trick.try(:is_not_over?) && current_player == next_player
  end
  
  def next_player
    last_trick.try(:next_player)
  end

  def last_trick
    last_round.try(:last_trick)
  end

  def played_cards
    last_trick.try(:played_cards)
  end
  
  def previous_trick
    last_round.try(:previous_trick)
  end
  
  def is_ready_for_a_new_trick?
    new_trick_time?
  end

  def is_ready_for_a_new_round?
    is_full? && new_round_time? && is_not_over?
  end

  def new_round_time?
    rounds.empty? || last_round.is_over?
  end

  def passing_time?
    last_round.try(:passing_time?) || false
  end

  def ready_to_pass?
    passing_time? && passing_sets_are_ready?
  end

  def new_trick_time?
    last_round.try(:is_ready_for_a_new_trick?) || false
  end

  def mid_trick_time?
    last_round.try(:has_an_active_trick?) || false
  end
  
  def trick_is_first?
    last_trick.trick_is_first?
  end
  
  def has_more_than_one_trick?
    last_trick.present? && last_round.tricks.length > 1
  end
  
  def computer_should_play?
    next_player.try(:is_computer?) && mid_trick_time?
  end
  
  def should_reload?(current_player)
    current_player.is_a_bystander? || master_should_reload(current_player)
  end
  
  def master_should_reload(master)
    if is_ready_for_a_new_round?
      false
    else
      rounds.empty? || waiting_for_others_to_pass?(master) || another_human_is_next?(master)
    end
  end
  
  def waiting_for_others_to_pass?(master)
    master.card_passing_set.is_ready && !passing_sets_are_ready?
  end
  
  def another_human_is_next?(current_player)
    next_player.try(:is_human?) && is_not_current_players_turn?(current_player)
  end
  
  def is_not_current_players_turn?(current_player)
    mid_trick_time? && next_player != current_player
  end
  
  def should_reload_and_wait?(current_player)
    is_current_players_turn?(current_player) || (passing_time? && current_player.has_not_passed_yet?)
  end
  
  def should_reload_previous_trick?
    last_round.try(:is_really_young?) || last_trick.try(:is_really_young?)
  end
  
  def update_scores_if_necessary
    if last_trick.is_over?
      last_round.calculate_round_scores
      if last_round.is_over?
        last_round.update_total_scores
        check_for_and_set_winner
      end
    end
  end
  
  def fill_empty_seats
    empty_seats.times do
      players.create(:seat => next_seat)
    end
  end

  private
  def passing_sets_are_ready?
    card_passing_sets.each do |set|
      return false if set.is_not_ready?
    end
    true
  end

  def check_for_and_set_winner
    players.each do |player|
      losing_score = (Rails.env == "test" ? 40 : 100)
      if player.reload.total_score >= losing_score
        self.update_attributes(:winner_id => find_lowest_player.id)
        return
      end
    end
  end

  def find_lowest_player
    min = 101
    winner = nil
    players.each do |player|
      if player.total_score <= min
        winner = player
        min = player.total_score
      end
    end  
    winner
  end

  def empty_seats
    4 - players.length
  end
  
  def next_dealer
    old_seat = last_round.dealer.seat
    new_seat = (old_seat + 1) % 4
    player_seated_at(new_seat)
  end

  def rounds_played
    rounds(true).length
  end

  def present_usernames
    players.map(&:username)
  end

  def can_accomodate(user)
    !(already_has?(user) || is_full?)
  end
  
end
