require 'ostruct'

module LiarsDice
  module Bots
    class DoyleBot
      attr_accessor :bid_list
      attr_reader :dice

      attr_accessor :total_dice

      def initialize(seat_number, player_count, dice_per_player)
        self.total_dice = player_count * dice_per_player
        self.bid_list = []
        # puts seat_number
      end

      def name
        "DoyleBot"
      end

      def handle_event(event)
        if event.is_a? LiarsDice::BidMadeEvent
          self.bid_list << event.bid
        elsif event.is_a? LiarsDice::LoserEvent
          self.total_dice -= 1
          self.bid_list = []
        end
      end

      def dice=(dice)
        @dice = dice
      end

      def bid
        last_bid = bid_list.last

        if last_bid and unreasonable(last_bid)
          return LiarsDice::BS.new
        end

        last_bid ||= OpenStruct.new(total: 1, face_value: 1)
        my_bid = LiarsDice::Bid.new(last_bid.total, last_bid.face_value)
        my_bid.face_value += 1
        if my_bid.face_value > 6
          my_bid.face_value = 2
          my_bid.total += 1
        end
        my_bid
      end

      def probability(bid)
        other_dice = total_dice - dice.length

        total = bid.total
        my_matches = dice.select{|i| i == bid.face_value || i == 1}.length
        total -= my_matches
        return 1 if total <= 0

        (1/3.0)**total / other_dice.to_f
      end

      def unreasonable(bid)
        other_dice = total_dice - dice.length

        total = bid.total
        my_matches = dice.select{|i| i == bid.face_value || i == 1}.length
        total -= my_matches
        return false if total <= 0

        total > (other_dice / 3.0 + 1)
      end
    end
  end
end
