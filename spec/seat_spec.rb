require 'spec_helper'

describe "Seat" do
  let (:player) { {} }
  let (:seat) { Seat.new(0, player, 5) }

  before do
    player.stub(:dice=)
  end

  describe "#alive?" do
    it "returns true when there are dice left" do
      seat.stub(:dice_left).and_return(4)
      seat.should be_alive
    end

    it "returns false when there are no dice left" do
      seat.stub(:dice_left).and_return(0)
      seat.should_not be_alive
    end
  end

  describe "#dice=" do
    it "passes the dice to the player" do
      player.should_receive(:dice=).with([1, 2, 3])
      seat.dice = [1,2,3]
    end
  end
end





