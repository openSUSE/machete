require File.expand_path(File.dirname(__FILE__) + "/machete/matchers")
require File.expand_path(File.dirname(__FILE__) + "/machete/parser")
require File.expand_path(File.dirname(__FILE__) + "/machete/version")

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

  # Finds all nodes in a Rubinius AST matching a pattern.
  #
  # @param [Rubinius::AST::Node] ast tree to search
  # @param [String, Machete::Matchers] pattern pattern to match the nodes against (see {file:README.md} for syntax description)
  #
  # @example
  #   Machete.find('42 + 43 + 44'.to_ast, 'FixnumLiteral')
  #   # => [
  #   #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
  #   #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
  #   #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
  #   #    ]
  # @example
  #   compiled_pattern = Machete::Parser.new.parse('FixnumLiteral')
  #   Machete.find('42 + 43 + 44'.to_ast, compiled_pattern)
  #   # => [
  #   #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
  #   #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
  #   #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
  #   #    ]
  #
  # @return [Array] list of matching nodes (in unspecified order)
  #
  # @raise [Matchete::Parser::SyntaxError] if the pattern is invalid
  def self.find(ast, pattern)
    if pattern.is_a? String
      matcher = Parser.new.parse(pattern)
    else
      matcher = pattern
    end

    result = []
    result << ast if matcher.matches?(ast)

    ast.walk(true) do |dummy, node|
      result << node if matcher.matches?(node)
      true
    end

    result
  end
end
