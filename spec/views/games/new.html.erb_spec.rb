require 'spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game,
      :room_id => 1,
      :size => 1,
      :winner_id => 1
    ).as_new_record)
  end

  it "renders new game form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => games_path, :method => "post" do
      assert_select "input#game_room_id", :name => "game[room_id]"
      assert_select "input#game_size", :name => "game[size]"
      assert_select "input#game_winner_id", :name => "game[winner_id]"
    end
  end
end
