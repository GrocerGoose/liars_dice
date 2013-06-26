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

  describe "#total_dice_numbered" do
    let(:seat0) { OpenStruct.new(dice: [1, 2, 3]) }
    let(:seat1) { OpenStruct.new(dice: [1, 2, 3]) }
    let(:seat2) { OpenStruct.new(dice: [1, 4, 5]) }

    before do
      engine.stub(:seats).and_return([seat0, seat1, seat2])
    end

    context "with wilds" do
      it "includes wilds when counting numbers" do
        engine.total_dice_numbered(3).should == 5
      end

      it "doesn't double count wilds" do
        engine.total_dice_numbered(1).should == 3
      end

      it "returns non-zero for every number" do
        6.times {|i| engine.total_dice_numbered(i+1).should > 0 }
      end
    end

    context "without wilds" do
      before do
        seat0.dice = [2, 2, 3]
        seat1.dice = [4, 2, 3]
        seat2.dice = [2, 4, 5]
      end

      it "returns the correct counts" do
        engine.total_dice_numbered(1).should == 0
        engine.total_dice_numbered(2).should == 4
        engine.total_dice_numbered(3).should == 2
        engine.total_dice_numbered(4).should == 2
        engine.total_dice_numbered(5).should == 1
        engine.total_dice_numbered(6).should == 0
      end
    end
  end

  describe "#bid_is_correct?" do
    let(:bid) { Bid.new(3, 3) }

    it "returns false when none of the numbers were rolled" do
      engine.stub(:total_dice_numbered).with(3).and_return(0)
      engine.bid_is_correct?(bid).should == false
    end

    it "returns false when less than total of the numbers were rolled" do
      engine.stub(:total_dice_numbered).with(3).and_return(1)
      engine.bid_is_correct?(bid).should == false
    end

    it "returns true when exactly total of the numbers were rolled" do
    engine.stub(:total_dice_numbered).with(3).and_return(3)
      engine.bid_is_correct?(bid).should == true
    end

    it "returns true when more than total of the numbers were rolled" do
    engine.stub(:total_dice_numbered).with(3).and_return(6)
      engine.bid_is_correct?(bid).should == true
    end
  end

  describe "#next_seat" do
    let(:seat1) { Seat.new(0, nil, 1) }
    let(:seat2) { Seat.new(0, nil, 1) }
    let(:seat3) { Seat.new(0, nil, 1) }

    it "only returns seats that are alive" do
      seat1.stub(:alive?).and_return(true)
      seat2.stub(:alive?).and_return(false)
      seat3.stub(:alive?).and_return(true)

      engine.stub(:seats).and_return([seat1, seat2, seat3])
      returned_seats = []
      3.times { returned_seats << engine.next_seat }
      returned_seats.should include(seat1)
      returned_seats.should_not include(seat2)
      returned_seats.should include(seat3)
    end

    it "wraps around if necessary" do
      seat1.stub(:alive?).and_return(true)
      seat2.stub(:alive?).and_return(false)
      seat3.stub(:alive?).and_return(true)

      engine.stub(:seats).and_return([seat1, seat2, seat3])
      returned_seats = []
      3.times { returned_seats << engine.next_seat }
      returned_seats.should == [seat1, seat3, seat1]
    end

    it "returns seats in order" do
      seat1.stub(:alive?).and_return(true)
      seat2.stub(:alive?).and_return(true)
      seat3.stub(:alive?).and_return(true)

      engine.stub(:seats).and_return([seat1, seat2, seat3])
      returned_seats = []
      3.times { returned_seats << engine.next_seat }
      returned_seats.should == [seat1, seat2, seat3]
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
      player1.should_receive(:handle_event).with(event)
      player2.should_receive(:handle_event).with(event)
      player3.should_receive(:handle_event).with(event)

      engine.notify_event(event)
    end
  end
end