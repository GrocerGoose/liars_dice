module LiarsDice
  class Engine
    include Watcher
    attr_accessor :seats, :starting_seat, :bids, :watcher
    attr_reader :loser, :seat_index

    def initialize(player_classes, dice_per_player, watcher=nil)
      self.seats = []
      player_classes.shuffle.each_with_index do |klass, i|
        player = klass.new(i, player_classes.count, dice_per_player)
        self.seats << Seat.new(i, player, dice_per_player)
      end
      self.seat_index = 0
      self.watcher = watcher || self
    end

    def run
      notify_seats
      until winner?
        roll_dice
        run_round
      end
      notify_winner
      nil
    end

    def get_bid(seat)
      seat.player.bid
    end

    def next_seat
      # If no seats are alive, we'd loop forever
      return nil if alive_seats.empty?

      seat = seats[seat_index]
      self.seat_index += 1

      # If the seat at seat_index is alive, return it
      # Otherwise, we've already updated seat_index (and wrapped it, if necessary)
      # so just call next_seat again
      seat.alive? ? seat : next_seat
    end

    def total_dice_with_face_value(face_value)
      seats.map{|seat| seat.dice.count(face_value) }.reduce(0, :+)
    end

    def bid_is_correct?(bid, use_wilds)
      total = total_dice_with_face_value(bid.face_value)
      total += total_dice_with_face_value(1) if use_wilds
      total >= bid.total
    end

    def run_round
      self.bids = []

      previous_seat = nil
      aces_wild = true
      while true
        seat = next_seat
        bid = get_bid(seat)

        # An invalid bid ends the round and costs the bidder a die
        unless valid_bid?(bid)
          self.loser = seat
          notify_invalid_bid(seat)
          break
        end

        # If someone calls BS, figure out the loser and exit the loop
        if bid.bs_called?
          notify_bs(seat)
          self.loser = bid_is_correct?(previous_bid, aces_wild) ? seat : previous_seat
          break
        end

        # For a valid, non-BS bid, update wilds, record and notify the bid and prepare for the next bid
        aces_wild = false if bid.face_value == 1
        self.bids << bid
        notify_bid(seat, bid)
        previous_seat = seat
      end

      # It's an error if we get here without having set a loser
      raise StandardError.new("Unknown loser") unless loser
      notify_loser(loser)
      loser.lose_die
    end

    def roll_dice
      die = (1..6).to_a
      alive_seats.each do |seat|
        dice = []
        seat.dice_left.times do
          dice << die.sample
        end

        seat.dice = dice
      end
      notify_roll
    end

    # ===========================================
    # ====        Notification Events        ====
    # ===========================================
    def notify_bid(seat, bid)
      event = BidMadeEvent.new(seat.number, bid)
      notify_players(event)
      notify_watcher(event)
    end

    def notify_bs(seat)
      event = BSCalledEvent.new(seat.number, previous_bid)
      notify_players(event)
      notify_watcher(event)
    end

    def notify_invalid_bid(seat)
      event = InvalidBidEvent.new(seat.number)
      notify_players(event)
      notify_watcher(event)
    end

    def notify_loser(seat)
      dice = seats.map(&:dice)
      event = LoserEvent.new(seat.number, dice)
      notify_players(event)
      notify_watcher(event)
    end

    def notify_winner
      event = WinnerEvent.new(winner.number)
      notify_players(event)
      notify_watcher(event)
    end

    def notify_roll
      dice = seats.map(&:dice)
      event = DiceRolledEvent.new(dice)
      notify_watcher(event)
    end

    def notify_seats
      event = SeatsAssignedEvent.new(seats)
      notify_watcher(event)
    end

    def notify_players(event)
      seats.each{|s| s.player.handle_event(event) }
    end

    def notify_watcher(event)
      watcher.handle_event(event)
    end

    # ===========================================
    # ====        Validation Methods         ====
    # ===========================================
    def valid_bs?(bid)
      # Cannot bid BS if there isn't a previous bid
      !!previous_bid
    end

    def valid_bid?(bid)
      return false unless bid

      if bid.bs_called?
        return valid_bs?(bid)
      end

      if bid.face_value < 1 || bid.face_value > 6
        # Can't bid a face_value that doesn't exist
        return false
      elsif bid.total < 1
        # Have to bid a positive total
        return false
      elsif previous_bid && bid.total < previous_bid.total
        # The total must be monotonically increasing
        return false
      elsif previous_bid && bid.total == previous_bid.total && bid.face_value <= previous_bid.face_value
        # If the total does not increase, the face_value must
        return false
      end

      true
    end

    def previous_bid
      bids[-1]
    end

    def alive_seats
      seats.select(&:alive?)
    end

    def winner?
      alive_seats.count == 1
    end

    def winner
      return nil unless winner?
      alive_seats.first
    end

    def loser=(seat)
      @loser = seat
      self.seat_index = seat.number + 1
    end

    def seat_index=(index)
      @seat_index = index
      @seat_index = 0 if @seat_index == seats.count
    end
  end
end
