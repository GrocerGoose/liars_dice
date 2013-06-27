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

    def valid?
      if face_value < 1 || face_value > 6
        # Can't bid a face_value that doesn't exist
        return false
      elsif total < 1
        # Have to bid a positive total
        return false
      end
      true
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
