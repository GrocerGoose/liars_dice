class Event
  attr_accessor :message

  def init(message)
    self.message = message
  end
end

class BidMadeEvent < Event
  attr_accessor :seat_number, :bid

  def init(seat_number, bid)
    self.seat_number = seat_number
    self.bid = bid
    super("Seat #{seat_number} bid #{bid.to_s}")
  end
end

class BSCalledEvent < Event
  attr_accessor :seat_number, :previous_bid

  def init(seat_number, previous_bid)
    self.seat_number = seat_number
    self.previous_bid = previous_bid
    super("Seat #{seat_number} called BS")
  end
end

class LoserEvent < Event
  attr_accessor :seat_number, :dice

  def init(seat_number, dice)
    self.seat_number = seat_number
    self.dice = dice
    super("Seat #{seat_number} lost a die")
  end
end

class WinnerEvent < Event
  attr_accessor :seat_number

  def init(seat_number)
    self.seat_number = seat_number
    super("Game is over.  Seat #{seat_number} is the winner.")
  end
end
