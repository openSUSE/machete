module Machete
  # @private
  module Matchers
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
        alternatives.any? { |a| a.matches?(node) }
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
          attrs.all? { |name, matcher| matcher.matches?(node.send(name)) }
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
    class StartsWithMatcher
      attr_reader :prefix

      def initialize(prefix)
        @prefix = prefix
      end

      def ==(other)
        other.instance_of?(self.class) && @prefix == other.prefix
      end

      def matches?(node)
        node.is_a?(String) && node.start_with?(@prefix)
      end
    end

    # @private
    class EndsWithMatcher
      attr_reader :suffix

      def initialize(suffix)
        @suffix = suffix
      end

      def ==(other)
        other.instance_of?(self.class) && @suffix == other.suffix
      end

      def matches?(node)
        node.is_a?(String) && node.end_with?(@suffix)
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
