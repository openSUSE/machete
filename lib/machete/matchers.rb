module Machete
  # @private
  module Matchers
    # @private
    class Quantifier
      # :min should be always set, :max can be nil (meaning infinity)
      attr_reader :matcher, :min, :max, :step

      def initialize(matcher, min, max, step)
        @matcher, @min, @max, @step = matcher, min, max, step
      end

      def ==(other)
        other.instance_of?(self.class) &&
          @matcher == other.matcher &&
          @min == other.min &&
          @max == other.max &&
          @step == other.step
      end
    end

    # @private
    class ChoiceMatcher
      attr_reader :alternatives

      def initialize(alternatives)
        @alternatives = alternatives
      end

      def ==(other)
        other.instance_of?(self.class) && @alternatives == other.alternatives
      end

      def matches?(node)
        @alternatives.any? { |a| a.matches?(node) }
      end
    end

    # @private
    class NodeMatcher
      attr_reader :class_name, :attrs

      def initialize(class_name, attrs = {})
        @class_name, @attrs = class_name, attrs
      end

      def ==(other)
        other.instance_of?(self.class) &&
          @class_name == other.class_name &&
          @attrs == other.attrs
      end

      def matches?(node)
        node.class == Rubinius::AST.const_get(@class_name) &&
          @attrs.all? { |name, matcher| matcher.matches?(node.send(name)) }
      end
    end

    # @private
    class ArrayMatcher
      attr_reader :items

      def initialize(items)
        @items = items
      end

      def ==(other)
        other.instance_of?(self.class) && @items == other.items
      end

      def matches?(node)
        return false unless node.is_a?(Array)

        match(@items, node)
      end

      private

      # Simple recursive algorithm based on the one for regexp matching
      # described in Beatiful Code (Chapter 1).
      def match(matchers, nodes)
        if matchers.empty?
          nodes.empty?
        elsif !matchers[0].is_a?(Quantifier)
          matchers[0].matches?(nodes[0]) && match(matchers[1..-1], nodes[1..-1])
        else
          quantifier = matchers[0]

          # Too little elements?
          return false if nodes.size < quantifier.min

          # Make sure at least min elements match.
          matches_min = nodes[0...quantifier.min].all? do |node|
            quantifier.matcher.matches?(node)
          end
          return false unless matches_min

          # Now try to match the remaining elements. The shortest match wins.
          i = quantifier.min
          max = if quantifier.max
            [quantifier.max, nodes.size].min
          else
            nodes.size
          end
          while i <= max
            return true if match(matchers[1..-1], nodes[i..-1])

            matches_next = nodes[i...(i + quantifier.step)].all? do |node|
              quantifier.matcher.matches?(node)
            end
            return false unless matches_next

            i += quantifier.step
          end

          # No match found.
          false
        end
      end
    end

    # @private
    class LiteralMatcher
      attr_reader :literal

      def initialize(literal)
        @literal = literal
      end

      def ==(other)
        other.instance_of?(self.class) && @literal == other.literal
      end

      def matches?(node)
        @literal == node
      end
    end


    # @private
    class StringRegexpMatcher
      attr_reader :regexp

      def initialize(regexp)
        @regexp = regexp
      end

      def ==(other)
        other.instance_of?(self.class) && @regexp == other.regexp
      end

      def matches?(node)
        node.is_a?(String) && node =~ @regexp
      end
    end

    # @private
    class SymbolRegexpMatcher < StringRegexpMatcher
      def matches?(node)
        node.is_a?(Symbol) && node.to_s =~ @regexp
      end
    end

    # @private
    class AnyMatcher
      def ==(other)
        other.instance_of?(self.class)
      end

      def matches?(node)
        true
      end
    end
  end
end
