module LiarsDice
  class CommandLineWatcher
    include Watcher

    attr_reader :names

    def initialize
      self.names = {}
      after_dice_rolled :print_dice
      after_bid lambda{|seat, bid| puts "#{name(seat, true)} bids #{bid}" }
      after_bs lambda{|seat| puts "#{name(seat)} calls BS" }
      after_game lambda{|winner| puts "Game over.  #{name(winner)} wins." }
      after_round lambda{|loser| puts "#{name(loser)} loses a die" }
      after_invalid_bid lambda{|seat| puts "#{name(seat)} made an invalid bid" }
      after_seats_assigned lambda{|assignments| self.names = assignments }
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

    def print_dice(dice)
      dice.each_with_index { |roll, seat| puts "#{name(seat, true)} Rolled: #{roll.inspect.to_s}" }
      all_dice = dice.flatten
      (1..6).to_a.each {|face_value| puts Bid.new(all_dice.select{|d| d == face_value}.count, face_value) }
    end
  end
end
