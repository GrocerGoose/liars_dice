module LiarsDice
  class Bid
    attr_accessor :total, :number

    def initialize(total, number)
      self.total = total
      self.number = number
    end

    def bs_called?
      false
    end

    def to_s
      "#{total} #{number}#{"s" if total > 1}"
    end
  end

  class BS < Bid
    def initialize
    end

    def bs_called?
      true
    end
  end
end
