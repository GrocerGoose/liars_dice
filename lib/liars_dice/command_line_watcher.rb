module LiarsDice
  class CommandLineWatcher
    include Watcher

    attr_accessor :names, :justification

    def initialize
      self.names = {}
      append_after_dice_rolled lambda{|dice| puts "Dice Rolled: #{dice.inspect.to_s}" }
      append_after_bid lambda{|seat, bid| puts "#{name(seat, true)} bids #{bid}" }
      append_after_bs lambda{|seat| puts "#{name(seat)} calls BS" }
      append_after_game lambda{|winner| puts "Game over.  #{name(winner)} wins." }
      append_after_round lambda{|loser| puts "#{name(loser)} loses a die" }
      append_after_invalid_bid lambda{|seat| puts "#{name(seat)} made an invalid bid" }
      append_after_seats_assigned lambda{|assignments| assignments.each{|number, name| puts "Seat #{number}: #{name}" } }
      append_after_seats_assigned method(:remember_names)
    end

    def name(seat_number, justified=false)
      (names[seat_number] || "Seat #{seat_number}").ljust(justified ? justification : 0)
    end

    def remember_names(assignments)
      self.justification = assignments.values.map{|klass| klass.length }.max
      assignments.each{|number, name| self.names[number] = name }
    end
  end
end
