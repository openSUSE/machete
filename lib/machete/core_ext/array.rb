class Array
  def to_m
    result = map { |item| item.to_m }.join(", ")
    "[#{result}]"
  end
end