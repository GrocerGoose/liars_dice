module LiarsDice
  module Bots
    class HumanBot
      attr_accessor :prev_bid, :dice, :seat_number, :name

      def initialize(seat_number, number_of_players, number_of_dice)
        self.seat_number = seat_number
        self.name = "HumanBot"
        puts "You're playing as HumanBot in seat #{seat_number}"
        puts "When asked for a bid, either enter <TOTAL> <FACE_VALUE> or BS"
      end

      def handle_event(event)
        if event.is_a? LiarsDice::BidMadeEvent
          self.prev_bid = event.bid
          return if event.seat_number.to_i == self.seat_number.to_i
          puts event.message
        elsif event.is_a? LiarsDice::BSCalledEvent
          return if event.seat_number.to_i == self.seat_number.to_i
          puts event.message
        elsif event.is_a? LiarsDice::LoserEvent
          puts "There were #{event.dice.flatten.select{|i| i == prev_bid.face_value or i == 1}.length} #{prev_bid.face_value}s"
          if event.seat_number == self.seat_number
            puts "You lose a die"
          else
            puts event.message
          end
          puts
          self.prev_bid = nil
        end
      end

      def format_event(event)
        return if event.seat_number.to_i == seat_number.to_i
        event.message
      end

      def dice=(dice)
        @dice = dice
        puts "Your dice are #{dice.inspect.to_s}"
      end

      def bid
        puts "You're bidding first" unless prev_bid

        print "What do you bid? "
        bid_string = gets.chomp
        if bid_string.downcase == "bs"
          return BS.new
        end
        parts = bid_string.split(" ").map(&:to_i)
        if parts.length == 2
          ret = Bid.new(*parts)
          return ret if ret.valid?
        end
        print "Invalid bid"
        return bid
      end
    end
  end
end
