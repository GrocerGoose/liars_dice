module LiarsDice
  module Bots
    class MollyBot
      attr_accessor :rounds, :dice, :prev_bid, :number_of_dice, :players, :seat, :bid_history, :total_dice

      def initialize(seat_number, number_of_players, number_of_dice)
        self.number_of_dice = number_of_dice
        self.players = number_of_players
        self.seat = seat_number
        self.bid_history = []
        self.total_dice = number_of_players * number_of_dice
        self.rounds = 0
      end

      def name
        "MollyBot"
      end

      def handle_event(event)
        if event.is_a? LiarsDice::BidMadeEvent
          self.bid_history << event.bid
          self.prev_bid = event.bid
        elsif event.is_a? LiarsDice::LoserEvent
          self.prev_bid = nil
          self.rounds += 1
        end
      end

      def dice=(dice)
        @dice = dice
      end

      def all_dice_count
        total_dice - rounds
      end

      def dice_count_of_bid
        return dice.count(prev_bid.face_value) + dice.count(1) unless one_played?
        dice.count(prev_bid.face_value)
      end

      def one_played?
        a = bid_history.collect{|b| b.face_value}
        a.any?{|v| v == 1}
      end

      def most_bid
        a = bid_history.collect{|b| b.face_value}
        freq = a.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
        a.sort_by { |v| freq[v] }.last
      end

      def bid_count
        bid_history.collect{|b| b.face_value}.count(prev_bid.face_value)
      end

      def starting_bid
        b = number_of_dice/3 - 1
        b = 1 if b < 1
        LiarsDice::Bid.new(b, [5, 6].sample)
      end

      def magic_number
        dice.count(prev_bid.face_value) + all_dice_count/(3*expected_prob)
      end

      def expected_prob
        return 2 if one_played?
        1
      end

      def comment
        [":-P", "Crap", "This just got interesting", ":-/"].sample
      end

      # 1/3 * total dice
      # number of time people have said a face value
      # number of the face value you have
      # total/3 + freq(most bid) + own dice

      def bid
        return starting_bid unless prev_bid
        if prev_bid.total >= all_dice_count/(2*expected_prob) && prev_bid.total > dice_count_of_bid
          # puts comment
          LiarsDice::BS.new
        elsif prev_bid.total < magic_number && magic_number < all_dice_count
          LiarsDice::Bid.new(prev_bid.total + 1, prev_bid.face_value)
        else
          r = LiarsDice::Bid.new(prev_bid.total, prev_bid.face_value + 1)
          if r.face_value > 6
            r.total += 1
            r.face_value = 2
          end
          r
        end
      end
    end
  end
end
