require File.expand_path(File.dirname(__FILE__) + "/machete/matchers")
require File.expand_path(File.dirname(__FILE__) + "/machete/parser")

module Machete
  # Matches a Rubinius AST node against a pattern.
  #
  # @param [Rubinius::AST::Node] node node to match
  # @param [String] pattern pattern to match the node against (see {file:README.md} for syntax description)
  #
  # @example Succesfull match
  #   Machete.matches?('foo.bar'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
  #   # => true
  #
  # @example Failed match
  #   Machete.matches?('42'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
  #   # => false
  #
  # @return [Boolean] +true+ if the node matches the pattern, +false+ otherwise
  #
  # @raise [Matchete::Parser::SyntaxError] if the pattern is invalid
  def self.matches?(node, pattern)
    Parser.new.parse(pattern).matches?(node)
  end
end
