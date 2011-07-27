require "spec_helper"

describe Machete do
  describe "matches?" do
    it "returns true when passed matching node and pattern" do
      Machete.matches?('42'.to_ast, 'FixnumLiteral<value = 42>').should be_true
    end

    it "returns false when passed non-matching node and pattern" do
      Machete.matches?('43'.to_ast, 'FixnumLiteral<value = 42>').should be_false
    end
  end
end
