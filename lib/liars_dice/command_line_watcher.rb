module LiarsDice
  class CommandLineWatcher
    include Watcher

    def initialize
      append_after_dice_rolled lambda{|dice| puts "Dice Rolled: #{dice.inspect.to_s}" }
      append_after_bid lambda{|seat, bid| puts "Seat #{seat} bids #{bid}" }
      append_after_bs lambda{|seat| puts "Seat #{seat} calls BS" }
      append_after_game lambda{|winner| puts "Game over.  Seat #{winner} wins." }
      append_after_round lambda{|loser| puts "Seat #{loser} loses a die" }
      append_after_seats_assigned lambda{|assignments| assignments.each{|number, name| puts "Seat #{number}: #{name}" } }
    end
  end
end
