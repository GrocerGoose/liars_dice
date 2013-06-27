module LiarsDice
  class HumanBot
    attr_accessor :prev_bid, :dice

    def initialize(seat_number, number_of_players, number_of_dice)
      puts "You're playing as HumanBot in seat #{seat_number}"
      puts "When asked for a bid, either enter <TOTAL> <FACE_VALUE> or BS"
    end


    def handle_event(event)
      if event.is_a? LiarsDice::BidMadeEvent
        self.prev_bid = event.bid
      elsif event.is_a? LiarsDice::LoserEvent
        self.prev_bid = nil
      end
    end

    def dice=(dice)
      @dice = dice
      puts "Your dice are #{dice.inspect.to_s}"
    end

    def bid
      if prev_bid
        puts "Previous bid was #{prev_bid}"
      else
        puts "You're bidding first"
      end

      print "What do you bid? "
      bid_string = gets.chomp
      if bid_string.downcase == "bs"
        return BS.new
      end
      parts = bid_string.split(" ").map(&:to_i)
      if parts.length == 2
        return Bid.new(*parts)
      end
      print "Invalid bid"
      return bid
    end
  end
end
