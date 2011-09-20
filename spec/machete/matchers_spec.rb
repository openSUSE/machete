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
      it "matches an array with matching items" do
        @matcher.matches?([42, 43, 44]).should be_true
      end

      it "does not match an array with non-matching items" do
        @matcher.matches?([45, 46, 47]).should be_false
      end

      it "does not match an array with different length" do
        @matcher.matches?([42, 43]).should be_false
        @matcher.matches?([42, 43, 44, 45]).should be_false
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

  describe StartsWithMatcher do
    before :each do
      @matcher = StartsWithMatcher.new("abcd")
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.prefix.should == "abcd"
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a StartsWithMatcher initialized with the same parameters" do
        @matcher.should == StartsWithMatcher.new("abcd")
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of StartsWithMatcher initialized with the same parameters" do
        class SubclassedStartsWithMatcher < StartsWithMatcher
        end

        @matcher.should_not == SubclassedStartsWithMatcher.new("abcd")
      end

      it "returns false when passed a StartsWithMatcher initialized with different parameters" do
        @matcher.should_not == StartsWithMatcher.new("efgh")
      end
    end

    describe "matches?" do
      it "matches a string starting with the prefix" do
        @matcher.matches?("abcdefgh").should be_true
      end

      it "does not match a string not starting with the prefix" do
        @matcher.matches?("efghijkl").should be_false
      end

      it "does not match some random object" do
        @matcher.matches?(Object.new).should be_false
      end
    end
  end

  describe EndsWithMatcher do
    before :each do
      @matcher = EndsWithMatcher.new("abcd")
    end

    describe "initialize" do
      it "sets attributes correctly" do
        @matcher.suffix.should == "abcd"
      end
    end

    describe "==" do
      it "returns true when passed the same object" do
        @matcher.should == @matcher
      end

      it "returns true when passed a EndsWithMatcher initialized with the same parameters" do
        @matcher.should == EndsWithMatcher.new("abcd")
      end

      it "returns false when passed some random object" do
        @matcher.should_not == Object.new
      end

      it "returns false when passed a subclass of EndsWithMatcher initialized with the same parameters" do
        class SubclassedEndsWithMatcher < EndsWithMatcher
        end

        @matcher.should_not == SubclassedEndsWithMatcher.new("abcd")
      end

      it "returns false when passed a EndsWithMatcher initialized with different parameters" do
        @matcher.should_not == EndsWithMatcher.new("efgh")
      end
    end

    describe "matches?" do
      it "matches a string ending with the suffix" do
        @matcher.matches?("efghabcd").should be_true
      end

      it "does not match a string not ending with the suffix" do
        @matcher.matches?("ijklefgh").should be_false
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
