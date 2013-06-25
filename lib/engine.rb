class Engine
  attr_accessor :seats, :starting_seat, :bids

  def init(player_classes, dice_per_player)
    seat = []
    player_classes.shuffle.each_with_index do |i, klass|
      player = klass.new(player_classes.count, dice_per_player, i)
      seats << Seat.new(i, player, dice_per_player)
    end
  end

  def roll
    seats.select(&:alive?).each do |seat|
      dice = []
      die = (1..6).to_a
      seat.dice_left.times do
        dice << die.sample
      end

      seat.dice = dice
    end
  end

  def notify_bid(bid)
    # TODO - send notification events
    nil
  end

  def valid_bid?(bid)
    if bid.bs_called? && prev_bid.nil?
      # Cannot bid BS if there are no bids
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

  def get_bid(seat)
    bid = seat.player.bid
    unless valid_bid?(bid)
      raise StandardError("Invalid Bid")
    end
    bid
  end

  def round
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

  def previous_bid
    bids[-1]
  end
end
