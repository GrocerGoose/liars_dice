Bid = Struct.new(:total, :number) do
  def to_s
    "#{total} #{number}s"
  end
end
