require "spec_helper"

module Machete::Matchers
  describe ChoiceMatcher do
    before :each do
      @alternatives = [
        LiteralMatcher.new(42),
        LiteralMatcher.new(43),
        LiteralMatcher.new(44)
      ]
      @matcher = ChoiceMatcher.new(@alternatives)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.alternatives.should == @alternatives
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a ChoiceMatcher initialized with the same parameters" do
        @matcher.should == ChoiceMatcher.new(@alternatives)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of ChoiceMatcher initialized with the same parameters" do
        class SubclassedChoiceMatcher < ChoiceMatcher
        end

        @matcher.should_not == SubclassedChoiceMatcher.new(@alternatives)
      end

      it "returns false when passed a ChoiceMatcher initialized with different parameters" do
        @matcher.should_not == ChoiceMatcher.new([
          LiteralMatcher.new(45),
          LiteralMatcher.new(46),
          LiteralMatcher.new(47)
        ])
      end
    end

    describe "matches?" do
      it "matches any alternative" do
        @matcher.matches?(42).should be_true
        @matcher.matches?(43).should be_true
        @matcher.matches?(44).should be_true
      end

      it "does not match a non-alternative" do
        @matcher.matches?(45).should be_false
      end
    end
  end

  describe NodeMatcher do
    before :each do
      @attrs = {
        :source  => LiteralMatcher.new("abcd"),
        :options => LiteralMatcher.new(128)
      }
      @matcher = NodeMatcher.new(:RegexLiteral, @attrs)
    end

    describe "initializa" do
      describe "when passed one parameter" do
        it "sets attributes correctly" do
          matcher = NodeMatcher.new(:RegexLiteral)

          matcher.class_name.should == :RegexLiteral
          matcher.attrs.should == {}
        end
      end

      describe "when passed two parameters" do
        it "sets attributes correctly" do
          matcher = NodeMatcher.new(:RegexLiteral, @attrs)

          matcher.class_name.should == :RegexLiteral
          matcher.attrs.should == @attrs
        end
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a NodeMatcher initialized with the same parameters" do
        @matcher.should == NodeMatcher.new(:RegexLiteral, @attrs)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of NodeMatcher initialized with the same parameters" do
        class SubclassedNodeMatcher < NodeMatcher
        end

        @matcher.should_not ==
          SubclassedNodeMatcher.new(:RegexLiteral, @attrs)
      end

      it "returns false when passed a NodeMatcher initialized with different parameters" do
        @matcher.should_not == NodeMatcher.new(:StringLiteral, {
          :source  => LiteralMatcher.new("abcd"),
          :options => LiteralMatcher.new(128)
        })
        @matcher.should_not == NodeMatcher.new(:RegexLiteral, {
          :source  => LiteralMatcher.new("efgh"),
          :options => LiteralMatcher.new(256)
        })
      end
    end

    describe "matches?" do
      it "matches a node with correct class and matching attributes" do
        @matcher.matches?(Rubinius::AST::RegexLiteral.new(0, "abcd", 128)).should be_true
      end

      it "does not match a node with incorrect class" do
        @matcher.matches?(Rubinius::AST::StringLiteral.new(0, "abcd")).should be_false
      end

      it "does not match a node with non-matching attributes" do
        @matcher.matches?(Rubinius::AST::RegexLiteral.new(0, "efgh", 128)).should be_false
        @matcher.matches?(Rubinius::AST::RegexLiteral.new(0, "efgh", 256)).should be_false
      end
    end
  end

  describe LiteralMatcher do
    before :each do
      @matcher = LiteralMatcher.new(42)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.literal.should == 42
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a LiteralMatcher initialized with the same parameters" do
        @matcher.should == LiteralMatcher.new(42)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of LiteralMatcher initialized with the same parameters" do
        class SubclassedLiteralMatcher < LiteralMatcher
        end

        @matcher.should_not == SubclassedLiteralMatcher.new(42)
      end

      it "returns false when passed a LiteralMatcher initialized with different parameters" do
        @matcher.should_not == LiteralMatcher.new(43)
      end
    end

    describe "matches?" do
      it "matches an object equivalent to the literal" do
        @matcher.matches?(42).should be_true
      end

      it "does not match an object not equivalent to the literal" do
        @matcher.matches?(43).should be_false
      end
    end
  end
end
