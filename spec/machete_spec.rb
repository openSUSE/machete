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

  describe "find" do
    before do
      # The same pattern in a string form and a compiled form.
      @patterns = [
        'FixnumLiteral',
        Machete::Matchers::NodeMatcher.new("FixnumLiteral")
      ]
    end

    it "returns [] when no node matches the pattern" do
      @patterns.each do |pattern|
        Machete.find('"abcd"'.to_ast, pattern).should == []
      end
    end

    it "returns root node if it matches the pattern" do
      @patterns.each do |pattern|
        nodes = Machete.find('42'.to_ast, pattern)

        nodes.size.should == 1
        nodes[0].should be_instance_of(Rubinius::AST::FixnumLiteral)
        nodes[0].value.should == 42
      end
    end

    it "returns child nodes if they match the pattern" do
      @patterns.each do |pattern|
        nodes = Machete.find('42 + 43 + 44'.to_ast, pattern).sort_by(&:value)

        nodes.size.should == 3
        nodes[0].should be_instance_of(Rubinius::AST::FixnumLiteral)
        nodes[0].value.should == 42
        nodes[1].should be_instance_of(Rubinius::AST::FixnumLiteral)
        nodes[1].value.should == 43
        nodes[2].should be_instance_of(Rubinius::AST::FixnumLiteral)
        nodes[2].value.should == 44
      end
    end
  end
end
