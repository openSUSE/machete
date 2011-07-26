require "spec_helper"

describe Machete do
  describe "matches?" do
    it "returns true when passed matching node and pattern" do
      Machete.matches?(
        Rubinius::AST::FixnumLiteral.new(1, 42),
        'FixnumLiteral<value = 42>')
    end

    it "returns false when passed non-matching node and pattern" do
      Machete.matches?(
        Rubinius::AST::FixnumLiteral.new(1, 43),
        'FixnumLiteral<value = 42>')
    end
  end
end
