module Machete
  module DSL
    class Builder
      RESERVED_WORDS = [
        "for", "if", "alias", "next", "not", "super", "when", "case",
        "while", "yield", "class", "module", "and", "break", "send",
      ].freeze

      attr_accessor :tree

      def self.build(type = :hash, &block)
        mb = Builder.new(type)
        mb.instance_eval(&block) if block_given?
        mb.tree
      end

      def self.dsl_method_name(name)
        method_name = underscore(name)
        prefix = RESERVED_WORDS.include?(method_name) ? "_" : ""

        prefix + method_name
      end

      def self.underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
      end

      Rubinius::AST.constants.each do |top_method|
        define_method dsl_method_name(top_method) do |*args, &block|
          __send__(top_method, *args, &block)
        end
      end

      def initialize(type = :hash)
        @tree = { :array => Array, :hash => Hash }[type].new
      end

      def method_missing(method, *args, &block)
        argument = args.first || :hash

        # fixnum_literal { ... }
        if block
          add_element(method, Builder.build(argument, &block))
        # fixnum_literal(value => 1) or fixnum_literal("value")
        elsif (argument.is_a?(Hash)) || (argument.is_a?(String))
          add_element(method, args.first)
        # fixnum_literal( [ symbol_literal(value => :symbol) ] )
        else
          {method => args.first}
        end
      end

      def add_element(method, item)
        if @tree.is_a? Hash
          @tree[method] = item
        else
          @tree << {method => item}
        end
      end
    end
  end
end