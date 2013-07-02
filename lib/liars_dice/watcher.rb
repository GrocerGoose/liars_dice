module LiarsDice
  module Watcher
    attr_reader :after_roll, :after_bid, :after_round, :after_bs, :after_game, :after_dice_rolled, :after_seats_assigned

    def append_after_bid(callback)
      append_callback(:after_bid, callback)
    end

    def append_after_round(callback)
      append_callback(:after_round, callback)
    end

    def append_after_bs(callback)
      append_callback(:after_bs, callback)
    end

    def append_after_game(callback)
      append_callback(:after_game, callback)
    end

    def append_after_dice_rolled(callback)
      append_callback(:after_dice_rolled, callback)
    end

    def append_after_seats_assigned(callback)
      append_callback(:after_seats_assigned, callback)
    end

    def handle_event(event)
      if event.is_a? BidMadeEvent
        fire(:after_bid, event.seat_number, event.bid)
      elsif event.is_a? BSCalledEvent
        fire(:after_bs, event.seat_number)
      elsif event.is_a? LoserEvent
        fire(:after_round, event.seat_number)
      elsif event.is_a? WinnerEvent
        fire(:after_game, event.seat_number)
      elsif event.is_a? DiceRolledEvent
        fire(:after_dice_rolled, event.dice)
      elsif event.is_a? SeatsAssignedEvent
        fire(:after_seats_assigned, event.seat_assignments)
      end
    end

    private
    def allowed_callbacks
      [:after_bid, :after_bs, :after_dice_rolled, :after_game, :after_round, :after_seats_assigned]
    end

    def append_callback(callback_name, callback)
      raise ArgumentError.new("Callback does not respond to call") unless callback.respond_to? :call
      raise ArgumentError.new("Unsupported callback #{callback_name}") unless allowed_callbacks.include? callback_name
      watcher_callbacks[callback_name] << callback
    end

    def fire(callback_name, *args)
      raise ArgumentError.new("Unsupported callback #{callback_name}") unless allowed_callbacks.include? callback_name
      watcher_callbacks[callback_name].each do |callback|
        callback.call(*args)
      end
    end

    def watcher_callbacks
      # Create a hash where any missing key returns an empty array
      @watcher_callbacks ||= Hash.new {|hash, key| hash[key] = [] }
    end
  end
end
