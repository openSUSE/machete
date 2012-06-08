require "spec_helper"

module Machete::Matchers
  describe Quantifier do
    before :each do
      @quantifier = Quantifier.new(LiteralMatcher.new(42), 0, 100, 10)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @quantifier.matcher.should == LiteralMatcher.new(42)
        @quantifier.min.should == 0
        @quantifier.max.should == 100
        @quantifier.step.should == 10
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @quantifier.should == @quantifier
      end

      it "returns true when passed a Quantifier initialized with the same parameters" do
        @quantifier.should == Quantifier.new(LiteralMatcher.new(42), 0, 100, 10)
      end

      it "returns false when passed some random object" do
        @quantifier.should_not == Object.new
      end

      it "returns false when passed a subclass of Quantifier initialized with the same parameters" do
        class SubclassedQuantifier < Quantifier
        end

        @quantifier.should_not ==
          SubclassedQuantifier.new(LiteralMatcher.new(42), 0, 100, 10)
      end

      it "returns false when passed a Quantifier initialized with different parameters" do
        @quantifier.should_not ==
          Quantifier.new(LiteralMatcher.new(43), 0, 100, 10)
        @quantifier.should_not ==
          Quantifier.new(LiteralMatcher.new(42), 1, 100, 10)
        @quantifier.should_not ==
          Quantifier.new(LiteralMatcher.new(42), 0, 101, 10)
        @quantifier.should_not ==
          Quantifier.new(LiteralMatcher.new(42), 0, 100, 11)
      end
    end
  end

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

  describe ArrayMatcher do
    before :each do
      @items = [
        LiteralMatcher.new(42),
        LiteralMatcher.new(43),
        LiteralMatcher.new(44)
      ]
      @matcher = ArrayMatcher.new(@items)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.items.should == @items
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a ArrayMatcher initialized with the same parameters" do
        @matcher.should == ArrayMatcher.new(@items)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of ArrayMatcher initialized with the same parameters" do
        class SubclassedArrayMatcher < ArrayMatcher
        end

        @matcher.should_not == SubclassedArrayMatcher.new(@items)
      end

      it "returns false when passed a ArrayMatcher initialized with different parameters" do
        @matcher.should_not == ArrayMatcher.new([
          LiteralMatcher.new(45),
          LiteralMatcher.new(46),
          LiteralMatcher.new(47)
        ])
      end
    end

    describe "matches?" do
      it "works on matcher with no items" do
        matcher = ArrayMatcher.new([])

        matcher.matches?([]).should be_true
        matcher.matches?([42]).should be_false
      end

      it "works on matcher with one item" do
        matcher = ArrayMatcher.new([LiteralMatcher.new(42)])

        matcher.matches?([]).should be_false
        matcher.matches?([42]).should be_true
        matcher.matches?([43]).should be_false
        matcher.matches?([42, 43]).should be_false
      end

      it "works on matcher with many items" do
        matcher = ArrayMatcher.new([
          LiteralMatcher.new(42),
          LiteralMatcher.new(43),
          LiteralMatcher.new(44)
        ])

        matcher.matches?([42, 43]).should be_false
        matcher.matches?([42, 43, 44]).should be_true
        matcher.matches?([43, 43, 44]).should be_false
        matcher.matches?([42, 44, 44]).should be_false
        matcher.matches?([42, 43, 45]).should be_false
        matcher.matches?([42, 43, 44, 45]).should be_false
      end

      it "works on matcher with a bound quantifier" do
        matcher = ArrayMatcher.new([
          Quantifier.new(LiteralMatcher.new(42), 1, 2, 1)
        ])

        matcher.matches?([]).should be_false
        matcher.matches?([42]).should be_true
        matcher.matches?([43]).should be_false
        matcher.matches?([42, 42]).should be_true
        matcher.matches?([43, 42]).should be_false
        matcher.matches?([42, 43]).should be_false
        matcher.matches?([42, 42, 42]).should be_false
      end

      it "works on matcher with a bound quantifier with a bigger step" do
        matcher = ArrayMatcher.new([
          Quantifier.new(LiteralMatcher.new(42), 1, 3, 2)
        ])

        matcher.matches?([]).should be_false
        matcher.matches?([42]).should be_true
        matcher.matches?([43]).should be_false
        matcher.matches?([42, 42]).should be_false
        matcher.matches?([42, 42, 42]).should be_true
        matcher.matches?([43, 42, 42]).should be_false
        matcher.matches?([42, 43, 42]).should be_false
        matcher.matches?([42, 42, 43]).should be_false
        matcher.matches?([42, 42, 42, 42]).should be_false
      end

      it "works on matcher with a bound quantifier and some items" do
        matcher = ArrayMatcher.new([
          LiteralMatcher.new(42),
          Quantifier.new(LiteralMatcher.new(43), 0, 1, 1),
          LiteralMatcher.new(44)
        ])

        matcher.matches?([42, 44]).should be_true
        matcher.matches?([42, 43, 44]).should be_true
        matcher.matches?([42, 44, 44]).should be_false
        matcher.matches?([42, 43, 43, 44]).should be_false
      end

      it "works on matcher with an unbound quantifier" do
        matcher = ArrayMatcher.new([
          Quantifier.new(LiteralMatcher.new(42), 1, nil, 1)
        ])

        matcher.matches?([]).should be_false
        matcher.matches?([42]).should be_true
        matcher.matches?([43]).should be_false
        matcher.matches?([42, 42]).should be_true
        matcher.matches?([43, 42]).should be_false
        matcher.matches?([42, 43]).should be_false
        matcher.matches?([42, 42, 42]).should be_true
        matcher.matches?([43, 42, 42]).should be_false
        matcher.matches?([42, 43, 42]).should be_false
        matcher.matches?([42, 42, 43]).should be_false
      end

      it "works on matcher with an unbound quantifier with a bigger step" do
        matcher = ArrayMatcher.new([
          Quantifier.new(LiteralMatcher.new(42), 1, nil, 2)
        ])

        matcher.matches?([]).should be_false
        matcher.matches?([42]).should be_true
        matcher.matches?([43]).should be_false
        matcher.matches?([42, 42]).should be_false
        matcher.matches?([42, 42, 42]).should be_true
        matcher.matches?([43, 42, 42]).should be_false
        matcher.matches?([42, 43, 42]).should be_false
        matcher.matches?([42, 42, 43]).should be_false
      end

      it "works on matcher with an unbound quantifier and some items" do
        matcher = ArrayMatcher.new([
          LiteralMatcher.new(42),
          Quantifier.new(LiteralMatcher.new(43), 0, nil, 1),
          LiteralMatcher.new(44)
        ])

        matcher.matches?([42, 44]).should be_true
        matcher.matches?([42, 43, 44]).should be_true
        matcher.matches?([42, 44, 44]).should be_false
        matcher.matches?([42, 43, 43, 44]).should be_true
        matcher.matches?([42, 44, 43, 44]).should be_false
        matcher.matches?([42, 43, 44, 44]).should be_false
        matcher.matches?([42, 43, 43, 43, 44]).should be_true
        matcher.matches?([42, 44, 43, 43, 44]).should be_false
        matcher.matches?([42, 43, 44, 43, 44]).should be_false
        matcher.matches?([42, 43, 43, 44, 44]).should be_false
      end

      it "does not match some random object" do
        @matcher.matches?(Object.new).should be_false
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

  describe SymbolRegexpMatcher do
    before do
      @matcher = SymbolRegexpMatcher.new(/abcd/)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.regexp.should == /abcd/
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a StartsWithMatcher initialized with the same parameters" do
        @matcher.should == SymbolRegexpMatcher.new(/abcd/)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of StartsWithMatcher initialized with the same parameters" do
        class SubclassedSymbolRegexpMatcher < SymbolRegexpMatcher
        end

        @matcher.should_not == SubclassedSymbolRegexpMatcher.new(/abcd/)
      end

      it "returns false when passed a StartsWithMatcher initialized with different parameters" do
        @matcher.should_not == SymbolRegexpMatcher.new(/efgh/)
      end
    end

    describe "matches?" do
      it "matches a string matching the regexp" do
        @matcher.matches?(:efghabcdijkl).should be_true
      end

      it "does not match a string not matching the regexp" do
        @matcher.matches?(:efghijkl).should be_false
      end

      it "does not match some random object" do
        @matcher.matches?(Object.new).should be_false
      end
    end
  end

  describe StringRegexpMatcher do
    before :each do
      @matcher = StringRegexpMatcher.new(/abcd/)
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.regexp.should == /abcd/
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a StartsWithMatcher initialized with the same parameters" do
        @matcher.should == StringRegexpMatcher.new(/abcd/)
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of StartsWithMatcher initialized with the same parameters" do
        class SubclassedStringRegexpMatcher < StringRegexpMatcher
        end

        @matcher.should_not == SubclassedStringRegexpMatcher.new(/abcd/)
      end

      it "returns false when passed a StartsWithMatcher initialized with different parameters" do
        @matcher.should_not == StringRegexpMatcher.new(/efgh/)
      end
    end

    describe "matches?" do
      it "matches a string matching the regexp" do
        @matcher.matches?("efghabcdijkl").should be_true
      end

      it "does not match a string not matching the regexp" do
        @matcher.matches?("efghijkl").should be_false
      end

      it "does not match some random object" do
        @matcher.matches?(Object.new).should be_false
      end
    end
  end

  describe AnyMatcher do
    before :each do
      @matcher = AnyMatcher.new
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of AnyMatcher" do
        class SubclassedAnyMatcher < AnyMatcher
        end

        @matcher.should_not == SubclassedAnyMatcher.new
      end
    end

    describe "matches?" do
      it "matches any object" do
        @matcher.matches?(Object.new)
      end
    end
  end
end
