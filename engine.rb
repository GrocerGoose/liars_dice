class Engine
  attr_accessor :seats, :starting_seat

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

  def valid_bid?(bid, bs_allowed=true)
    # TODO - validate bids
    true
  end

  def round
    # TODO - log bids
    index = starting_seat
    seat = seats[index]
    bid = seat.bid
    unless valid_bid?(bid, false)
      raise StandardError("Invalid Bid")
    end
    notify_bid(bid)
    index += 1

    while True
      index = 0 if index > seats.count
      seat = seats[index]
      if seat.lost?
        index += 1
        next
      end

      bid = seat.bid
      if bid.bs_called?
        notify_bs(bid)
        break
      end

      notify_bid(bid)
      index += 1
    end
  end

  def init(player_classes, dice_per_player)
    seat = []
    player_classes.shuffle.each_with_index do |i, klass|
      player = klass.new(player_classes.count, dice_per_player, i)
      seats << Seat.new(i, player, dice_per_player)
    end
  end
end
