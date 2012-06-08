require "spec_helper"

describe "patterns" do
  describe "method name" do
    it "returns true when method name is equal" do
      Machete.matches?('find_by_id'.to_ast, 'Send<name = :find_by_id>').should be_true
    end

    it "returns true when method name begins with find" do
      Machete.matches?('find_by_id'.to_ast, 'Send<name ^= :find>').should be_true
    end

    it "return false when method name does not begin with find" do
      Machete.matches?('find_by_id'.to_ast, 'Send<name ^= :_find>').should be_false
    end
  end
end