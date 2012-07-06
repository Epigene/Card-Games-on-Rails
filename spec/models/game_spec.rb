require 'spec_helper'

describe Game do

  before :all do
    @game = Game.create(:size => 4)
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @user3 = FactoryGirl.create(:user)
    @user4 = FactoryGirl.create(:user)
    @user1.update_attributes(:game_id => @game.id)
    @user2.update_attributes(:game_id => @game.id)
    @user3.update_attributes(:game_id => @game.id)
    @user4.update_attributes(:game_id => @game.id)
    @deck = FactoryGirl.create(:deck)
  end
  
  after :all do
    User.delete_all
    Game.delete_all
    Deck.delete_all
  end

  describe "#setup" do

    context "#new_game" do

      it "should show that game has been initiated" do
        @game.should be_an_instance_of Game
      end
      
      it "should not be over already" do
        @game.game_over?.should == false
      end
      
      it "should know it's size" do
        @game.size.should == 4
      end
      
    end
    
    pending "#deck" do
      
      before :all do
        @deck.game_id = @game.id
        @deck.save
      end
      it "should know about it's deck" do
        @game.deck.should be_an_instance_of Deck
      end
      
    end
    
    context "#players" do
      
      it "should know about it's players" do
        @game.players.length.should == 4
      end

    end

  end

  describe "#methods" do
    
    context "reset_for_new_game" do
      
      it "should work" do
        @game.update_attributes(:winner_id => 2)
        @game.winner_id.should == 2
        @game.reset_for_new_game
        @game.winner_id.should == nil
      end
    end
    
    context "clear_players_game_ids" do
      
      it "should work" do
        @game.clear_players_game_ids
        @game.players.each do |player|
          player.game_id.should == nil
        end
      end
    end
    
  end
end
