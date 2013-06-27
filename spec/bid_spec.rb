require 'spec_helper'

describe "Bid" do
  describe "#valid?" do
    it "returns false if total is negative" do
      bid = Bid.new(-1, 5)
      bid.should_not be_valid
    end

    it "returns false if total is negative" do
      bid = Bid.new(0, 5)
      bid.should_not be_valid
    end

    it "returns false for invalid die face_values" do
      bid = Bid.new(5, 0)
      bid.should_not be_valid

      bid = Bid.new(5, 10)
      bid.should_not be_valid
    end

    it "returns true for valid bids" do
      bid = Bid.new(5, 3)
      bid.should be_valid
    end
  end
end
