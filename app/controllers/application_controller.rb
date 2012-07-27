class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  include SimplestAuth::Controller
  include CardGames::Authentication
  
  def current_player
    current_user.try(:current_player)
  end
  
  def assign_game
    id = params[:id] || params[:game_id]
    @game = Game.find(id)
  end
  
  def assign_variables 
    assign_game
    
    @hand = current_player.try(:hand)
    @lead_suit = @game.get_lead_suit
    @my_turn = @game.is_current_player_next?(current_player)

    @played_cards = @game.played_cards
  end
  
  def reload_game_page(partial = "shared/game_page")
    respond_to do |format|
      format.html {
        if request.xhr?
          assign_variables
          render :partial => partial
        else
          redirect_to @game
        end
      }
    end
  end
  
end
