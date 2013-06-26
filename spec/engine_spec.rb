require 'spec_helper'

describe "Engine" do
  let(:engine) { Engine.new([], 5) }
  describe "valid_bid?" do
    before do
      engine.stub(:previous_bid).and_return(nil)
    end

    context "when given a BS object" do
      it "calls valid_bs?" do
        engine.should_receive(:valid_bs?)
        engine.valid_bid?(BS.new)
      end

      it "returns the result of valid_bs?" do
        engine.stub(:valid_bs?).and_return("foobar")
        engine.valid_bid?(BS.new).should == "foobar"
      end
    end

    it "returns false if total is negative" do
      bid = Bid.new(-1, 5)
      engine.valid_bid?(bid).should == false
    end

    it "returns false for invalid die numbers" do
      bid = Bid.new(5, 0)
      engine.valid_bid?(bid).should == false
      bid = Bid.new(5, 10)
      engine.valid_bid?(bid).should == false
    end

    context "with a previous bid" do
      before do
        prev = Bid.new(3, 3)
        engine.stub(:previous_bid).and_return(prev)
      end

      # Possibilities:
      it "returns false if the total goes down and the number goes down" do
        bid = Bid.new(2, 2)
        engine.valid_bid?(bid).should == false
      end

      it "returns false if the total goes down and the number stays the same" do
        bid = Bid.new(2, 3)
        engine.valid_bid?(bid).should == false
      end

      it "returns false if the total goes down and the number goes up" do
        bid = Bid.new(2, 4)
        engine.valid_bid?(bid).should == false
      end

      it "returns false if the total stays the same and the number goes down" do
        bid = Bid.new(3, 2)
        engine.valid_bid?(bid).should == false
      end

      it "returns false if the total stays the same and the number stays the same" do
        bid = Bid.new(3, 3)
        engine.valid_bid?(bid).should == false
      end

      it "returns true if the total stays the same and the number goes up" do
        bid = Bid.new(3, 4)
        engine.valid_bid?(bid).should == true
      end

      it "returns true if the total goes up and the number goes down" do
        bid = Bid.new(4, 2)
        engine.valid_bid?(bid).should == true
      end

      it "returns true if the total goes up and the number stays even" do
        bid = Bid.new(4, 3)
        engine.valid_bid?(bid).should == true
      end

      it "returns true if the total stays even and the number goes up" do
        bid = Bid.new(4, 4)
        engine.valid_bid?(bid).should == true
      end
    end
  end
end
