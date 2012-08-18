require File.expand_path(File.dirname(__FILE__) + "/machete/matchers")
require File.expand_path(File.dirname(__FILE__) + "/machete/parser")
require File.expand_path(File.dirname(__FILE__) + "/machete/version")

module Machete
  class << self
    # Matches a Rubinius AST node against a pattern.
    #
    # @param [Rubinius::AST::Node] node node to match
    # @param [String, Machete::Matchers::Matcher] pattern pattern to match the
    #   node against, either as a string (see {file:README.md} for syntax
    #   description) or in compiled form
    #
    # @example Test using a string pattern
    #   Machete.matches?('foo.bar'.to_ast, 'Send<name = :bar>')
    #   # => true
    #
    #   Machete.matches?('42'.to_ast, 'Send<name = :bar>')
    #   # => false
    #
    # @example Test using a compiled pattern
    #   Machete.matches?(
    #     'foo.bar'.to_ast,
    #     Machete::Matchers::NodeMatcher.new("Send",
    #       :name => Machete::Matchers::LiteralMatcher.new(:bar)
    #     )
    #   )
    #   # => true
    #
    #   Machete.matches?(
    #     '42'.to_ast,
    #     Machete::Matchers::NodeMatcher.new("Send",
    #       :name => Machete::Matchers::LiteralMatcher.new(:bar)
    #     )
    #   )
    #   # => false
    #
    # @return [Boolean] +true+ if the node matches the pattern, +false+
    #   otherwise
    #
    # @raise [Matchete::Parser::SyntaxError] if the pattern is invalid
    def matches?(node, pattern)
      compiled_pattern(pattern).matches?(node)
    end

    # Finds all nodes in a Rubinius AST matching a pattern.
    #
    # @param [Rubinius::AST::Node] ast tree to search
    # @param [String, Machete::Matchers::Matcher] pattern pattern to match the
    #   nodes against, either as a string (see {file:README.md} for syntax
    #   description) or in compiled form
    #
    # @example Search using a string pattern
    #   Machete.find('42 + 43 + 44'.to_ast, 'FixnumLiteral')
    #   # => [
    #   #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
    #   #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
    #   #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
    #   #    ]
    #
    # @example Search using a compiled pattern
    #   Machete.find(
    #     '42 + 43 + 44'.to_ast,
    #     Machete::Matchers::NodeMatcher.new("FixnumLiteral")
    #   )
    #   # => [
    #   #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
    #   #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
    #   #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
    #   #    ]
    #
    # @return [Array] list of matching nodes (in unspecified order)
    #
    # @raise [Matchete::Parser::SyntaxError] if the pattern is invalid
    def find(ast, pattern)
      matcher = compiled_pattern(pattern)

      result = []
      result << ast if matcher.matches?(ast)

      ast.walk(true) do |dummy, node|
        result << node if matcher.matches?(node)
        true
      end

      result
    end

    private

    def compiled_pattern(pattern)
      if pattern.is_a?(String)
        Parser.new.parse(pattern)
      else
        pattern
      end
    end
  end
end
