module LiarsDice
  class CommandLineWatcher
    include Watcher

    attr_reader :names

    def initialize
      self.names = {}
      append_after_dice_rolled lambda{|dice| puts "Dice Rolled: #{dice.inspect.to_s}" }
      append_after_bid lambda{|seat, bid| puts "#{name(seat, true)} bids #{bid}" }
      append_after_bs lambda{|seat| puts "#{name(seat)} calls BS" }
      append_after_game lambda{|winner| puts "Game over.  #{name(winner)} wins." }
      append_after_round lambda{|loser| puts "#{name(loser)} loses a die" }
      append_after_invalid_bid lambda{|seat| puts "#{name(seat)} made an invalid bid" }
      append_after_seats_assigned lambda{|assignments| self.names = assignments }
    end

    def name(seat_number, justified=false)
      (names[seat_number] || "Seat #{seat_number}").ljust(justified ? justification : 0)
    end

    def justification
      @justification ||= names.values.map(&:length).max
      @justification
    end

    def names=(value)
      @names = value
      @names.each{|number, name| puts "Seat #{number}: #{name}" }
    end
  end
end
