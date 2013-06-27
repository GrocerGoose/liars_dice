module LiarsDice
  class Bid
    attr_accessor :total, :face_value

    def initialize(total, face_value)
      self.total = total
      self.face_value = face_value
    end

    def bs_called?
      false
    end

    def to_s
      "#{total} #{face_value}#{"s" if total > 1}"
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
