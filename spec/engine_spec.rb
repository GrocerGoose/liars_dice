require 'spec_helper'

describe "Engine" do
  let(:engine) { Engine.new([], 5) }
  let(:seat) { Seat.new(0, nil, 5) }

  describe "#get_bid" do
    before do
      seat.stub_chain(:player, :bid).and_return("bid")
    end

    it "gets a bid from the seat's user" do
      engine.stub(:valid_bid?).and_return(true)
      engine.get_bid(seat).should == "bid"
    end

    it "raises an error if given an invalid bid" do
      engine.stub(:valid_bid?).and_return(false)
      expect { engine.get_bid(seat) }.to raise_error
    end
  end

  describe "#roll_dice" do
    context "randomness" do
      before do
        # Roll the dice a bunch of times and capture the result in a hash
        # keyed by die number
        engine.stub(:alive_seats).and_return([seat])
        seat.stub(:dice_left).and_return(6000)
        rolled_dice = []
        seat.stub(:dice=) { |val| rolled_dice = val }
        engine.roll_dice
        @histogram = Hash.new(0)
        rolled_dice.each{|die| @histogram[die] += 1 }
      end

      it "chooses valid numbers" do
        @histogram.keys.sort.should == [1,2,3,4,5,6]
      end

      it "randomly distributes numbers" do
        6.times do |i|
          @histogram[i+1].should > 800
          @histogram[i+1].should < 1200
        end
      end
    end

    it "only rolls dice for seats that are alive" do
      s1 = Seat.new(0, {}, 5)
      s1.stub(:alive?).and_return(false)
      s2 = Seat.new(1, {}, 5)
      s2.stub(:alive?).and_return(true)
      engine.stub(:seats).and_return([s1, s2])
      s1.should_not_receive(:dice=)
      s2.should_receive(:dice=)
      engine.roll_dice
    end

    it "rolls the correct number of dice for each seat" do
      s1 = Seat.new(0, {}, 5)
      s1.stub(:dice_left).and_return(3)
      s1.stub(:dice=) { |val| val.count.should == 3 }
      s2 = Seat.new(1, {}, 5)
      s2.stub(:dice_left).and_return(5)
      s2.stub(:dice=) { |val| val.count.should == 5 }

      engine.stub(:alive_seats).and_return([s1, s2])
      engine.roll_dice
    end
  end

  describe "#valid_bid?" do
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
        @prev = Bid.new(3, 3)
        engine.stub(:previous_bid).and_return(@prev)
      end

      it "validates all the possible bids correctly" do
        [[-1, -1, false],
         [-1, 0, false],
         [-1, 1, false],
[-1, -1, false],
         [-1, 0, false],
         [-1, 1, false],
         [-1, -1, false],
         [-1, 0, false],
         [-1, 1, false]].each do |total_delta, number_delta, result|
          bid = Bid.new(@prev.total + total_delta, @prev.number + number_delta)
          engine.valid_bid?(bid).should == result
        end
      end
    end
  end

  describe "#valid_bs?" do
    it "returns true if there's a previous bid" do
      prev = Bid.new(3, 3)
      engine.stub(:previous_bid).and_return(prev)
      engine.valid_bs?(BS.new).should == true
    end

    it "returns false if there's not a previous bid" do
      engine.stub(:previous_bid).and_return(nil)
      engine.valid_bs?(BS.new).should == false
    end
  end

  describe "#alive_seats" do
    it "doesn't return any seats that aren't alive" do
      s1 = Seat.new(0, nil, 6)
      s2 = Seat.new(0, nil, 6)
      s1.stub(:alive?).and_return(true)
      s2.stub(:alive?).and_return(false)
      engine.stub(:seats).and_return([s1, s2])
      engine.alive_seats.should == [s1]
    end
  end

  describe "notify_bid" do
    it "passes an BidMadeEvent to notify_event" do
      engine.should_receive(:notify_event).with(an_instance_of(BidMadeEvent))
      engine.notify_bid(seat, nil)
    end
  end

  describe "notify_bs" do
    it "passes an BSCalledEvent to notify_event" do
      engine.stub(:previous_bid).and_return(nil)
      engine.should_receive(:notify_event).with(an_instance_of(BSCalledEvent))
      engine.notify_bs(seat)
    end
  end

  describe "notify_loser" do
    it "passes an LoserEvent to notify_event" do
      engine.should_receive(:notify_event).with(an_instance_of(LoserEvent))
      engine.stub(:seats).and_return([])
      engine.notify_loser(seat)
    end
  end

  describe "notify_winner" do
    it "passes an WinnerEvent to notify_event" do
      engine.should_receive(:notify_event).with(an_instance_of(WinnerEvent))
      engine.notify_winner(seat)
    end
  end

  describe "notify_event" do
    it "passes the event to all players" do
      player1 = {}
      s1 = Seat.new(0, player1, 5)
      player2 = {}
      s2 = Seat.new(0, player2, 5)
      player3 = {}
      s3 = Seat.new(0, player3, 5)
      engine.stub(:seats).and_return([s1, s2, s3])

      event = WinnerEvent.new(seat)
      player1.should_receive(:notify).with(event)
      player2.should_receive(:notify).with(event)
      player3.should_receive(:notify).with(event)

      engine.notify_event(event)
    end
  end
end
