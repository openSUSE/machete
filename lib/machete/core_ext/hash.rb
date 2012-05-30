class Hash
  def to_m
    result = []
    each do |key, value|
      # When the key in hash starts with a capital letter it means that it is a Rubinius::AST tree object
      # otherwise it is an argument for Rubinius::AST object.
      #
      # :FixnumLiteral => { :attribute => 1 }
      # => FixnumLiteral<attribute = 1>
      chunk = key =~ /^[A-Z]/ ? "#{key}<#{value.to_m}>" : "#{key} = #{value.to_m}"
      result << chunk
    end

    result.join(", ")
  end
end