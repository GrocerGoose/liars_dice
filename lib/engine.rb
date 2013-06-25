class Engine
  attr_accessor :seats, :starting_seat, :bids

  def init(player_classes, dice_per_player)
    seat = []
    player_classes.shuffle.each_with_index do |i, klass|
      player = klass.new(player_classes.count, dice_per_player, i)
      seats << Seat.new(i, player, dice_per_player)
    end
  end

  def run
    while seats.any?(&:alive?)
      roll_dice
      run_round
    end
    notify_winner(seats.detect(&:alive?))
  end

  def get_bid(seat)
    bid = seat.player.bid
    unless valid_bid?(bid)
      raise StandardError("Invalid Bid")
    end
    bid
  end

  def run_round
    bids = []
    index = starting_seat
    seat = seats[index]
    bid = get_bid(seat)
    notify_bid(bid)
    index += 1

    while True
      index = 0 if index > seats.count
      seat = seats[index]
      if seat.lost?
        index += 1
        next
      end

      bid = get_bid(seat)
      if bid.bs_called?
        notify_bs(bid)
        break
      end

      notify_bid(bid)
      index += 1
    end
  end

  def roll_dice
    die = (1..6).to_a
    seats.select(&:alive?).each do |seat|
      dice = []
      seat.dice_left.times do
        dice << die.sample
      end

      seat.dice = dice
    end
  end

  # ===========================================
  # ====        Notification Events        ====
  # ===========================================
  def notify_bid(seat, bid)
    event = BidMadeEvent.new(seat.number, bid)
    notify_event(event)
  end

  def notify_bs(seat)
    event = BSCalledEvent.new(seat.number, previous_bid)
    notify_event(event)
  end

  def notify_loser(seat)
    dice = seats.map(&:dice)
    event = LoserEvent.new(seat, dice)
    notify_event(event)
  end

  def notify_winner(seat)
    event = WinnerEvent.new(seat)
    notify_event(event)
  end

  def notify_event(event)
    seats.each{|s| s.player.notify(event) }
  end

  # ===========================================
  # ====        Validation Methods         ====
  # ===========================================
  def valid_bs?(bid)
    # Cannot bid BS if there isn't a previous bid
    !!previous_bid
  end

  def valid_bid?(bid)
    if bid.bs_called?
      return valid_bs?(bid)
    end

    if bid.number < 1 || bid.number > 6
      # Can't bid a number that doesn't exist
      return false
    elsif bid.total < prev_bid.total
      # The total must be monotonically increasing
      return false
    elsif bid.total == prev_bid.total && bid.number <= prev_bid.number
      # If the total does not increase, the number must
      return false
    end

    true
  end

  def previous_bid
    bids[-1]
  end
end
