class Engine
  attr_accessor :seats

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

  def init(player_classes, dice_per_player)
    seat = []
    player_classes.shuffle.each_with_index do |i, klass|
      player = klass.new(player_classes.count, dice_per_player, i)
      seats << Seat.new(i, player, dice_per_player)
    end
  end
end
