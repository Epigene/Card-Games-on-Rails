class CardPassingsController < ApplicationController

  before_filter :assign_game

  def create
    current_round.pass_cards
    reload_game_page
  end

  def flip_passing_status
    player_choice = PlayerCard.find(params[:card].to_i)
    player_choice.flip_passing_status
    reload_game_page("shared/my_hand")
  end
  
  def passing_set_ready
    current_player.card_passing_set.update_attributes(:is_ready => true)
    reload_game_page("shared/nothing")
  end

end
