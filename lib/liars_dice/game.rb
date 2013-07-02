module LiarsDice
  class Game
    def self.play(bot_classes)
      self.new.play(bot_classes)
    end

    def play(bot_classes)
      w = LiarsDice::CommandLineWatcher.new
      w.append_after_round lambda { |*args| gets }
      e = LiarsDice::Engine.new(bot_classes, 5, w)
      e.run
    end
  end
end
