module LiarsDice
  module Bots
    class RandomBot
      attr_accessor :prev_bid

      def initialize(seat_number, number_of_players, number_of_dice); end


      def handle_event(event)
        if event.is_a? LiarsDice::BidMadeEvent
          self.prev_bid = event.bid
        elsif event.is_a? LiarsDice::LoserEvent
          self.prev_bid = nil
        end
      end

      def dice=(dice); end

      def bid
        if prev_bid
          choice = (0...10).to_a.sample

          if choice == 0
            # Call BS 10% of the time
            LiarsDice::BS.new
          elsif choice <= 6
            # Up the total 50% of the time
            LiarsDice::Bid.new(prev_bid.total + 1, prev_bid.face_value)
          else
            # Up the number 40% of the time
            r = LiarsDice::Bid.new(prev_bid.total, prev_bid.face_value + 1)
            if r.face_value > 6
              r.total += 1
              r.face_value = 2
            end
            r
          end
        else
          LiarsDice::Bid.new(1, 2)
        end
      end
    end
  end
end
