module LiarsDice
  module Bots
    class SchmeckBot
      attr_accessor :total_dice, :dice, :probabilities, :aces_wild, :previous_bid

      def initialize(seat_number, number_of_players, dice_per_player)
        self.total_dice = number_of_players * dice_per_player
      end

      def name
        "SchmeckBot"
      end

      def dice=(arr)
        @dice = arr
        self.aces_wild = true
        update_probabilities
      end

      def bid
        if previous_bid
          # If we know the bid is bad based off the dice in our hand and the number of remaining dice, call BS automatically
          return LiarsDice::BS.new if known_bad(previous_bid)

          # Never call BS if the previous bid will be correct based solely off the dice in our roll
          allow_bs = !known_good(previous_bid)
          next_bid(allow_bs) || LiarsDice::BS.new
        else
          first_bid
        end
      end

      def handle_event(event)
        if event.is_a? LiarsDice::BidMadeEvent
          self.aces_wild = false if event.bid.face_value == 1
          self.previous_bid = event.bid
        elsif event.is_a? LiarsDice::LoserEvent
          self.total_dice -= 1
          self.previous_bid = nil
        end
      end

      def update_probabilities
        self.probabilities = {}

        (1..6).to_a.each do |i|
          self.probabilities[i] = guess_number_of_dice(i)
        end
      end

      def count_number_of_dice(face_value)
        ret = dice.select{|d| d == face_value }.count
        ret += dice.select{|d| d == 1 }.count if aces_wild && face_value != 1
        return ret
      end

      def number_of_other_dice
        total_dice - dice.count
      end

      def guess_number_of_dice(face_value)
        pr_face_value = (aces_wild && face_value != 1) ? 1.0 / 3 : 1.0 / 6
        count_number_of_dice(face_value) + pr_face_value * number_of_other_dice
      end

      def first_bid
        tmp = probabilities.sort_by{|face_value, guess| guess }.last
        LiarsDice::Bid.new([1, tmp[1].floor - 2].max, tmp[0])
      end

      def next_bid(allow_bs=true)
        score = -100000
        winner = nil
        possible_bids do |bid|
          bid_score = score(bid)
          if bid_score > score
            winner = bid
            score = bid_score
          end
        end

        (score < 0 && allow_bs) ? nil : winner
      end

      # Generate the bids possible by incrementing 1
      def possible_bids
        (6 - previous_bid.face_value).times do |i|
          # Holding total constant, go up in face value
          yield LiarsDice::Bid.new(previous_bid.total, previous_bid.face_value + i + 1)
        end
        (previous_bid.face_value).times do |i|
          # Increment bid by one, and look at all face values <= the previous face value
          yield LiarsDice::Bid.new(previous_bid.total + 1, i + 1)
        end
      end

      def score(bid)
        probabilities[bid.face_value] - bid.total
      end

      # We know a bid is good if we have at least that many dice in our hand
      def known_good(bid)
        count_number_of_dice(bid.face_value) >= bid.total
      end

      # We know a bid is bad if there's no way there could be that many dice on the table
      def known_bad(bid)
        bid.total - count_number_of_dice(bid.face_value) > number_of_other_dice
      end
    end
  end
end
