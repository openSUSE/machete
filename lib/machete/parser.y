class Machete::Parser

token VAR_NAME
token CLASS_NAME
token SYMBOL
token INTEGER
token STRING

start expression

rule

expression : primary
           | expression "|" primary {
               result = if val[0].is_a?(ChoiceMatcher)
                 ChoiceMatcher.new(val[0].alternatives << val[2])
               else
                 ChoiceMatcher.new([val[0], val[2]])
               end
             }

primary : node
        | literal

node : CLASS_NAME {
         result = NodeMatcher.new(val[0].to_sym)
       }
     | CLASS_NAME "<" attrs ">" {
         result = NodeMatcher.new(val[0].to_sym, val[2])
       }

attrs : attr
      | attrs "," attr { result = val[0].merge(val[2]) }

attr : VAR_NAME "=" expression { result = { val[0].to_sym => val[2] } }

literal : SYMBOL  { result = LiteralMatcher.new(val[0][1..-1].to_sym) }
        | INTEGER {
            value = if val[0] =~ /^0[bB]/
              val[0][2..-1].to_i(2)
            elsif val[0] =~ /^0[oO]/
              val[0][2..-1].to_i(8)
            elsif val[0] =~ /^0[dD]/
              val[0][2..-1].to_i(10)
            elsif val[0] =~ /^0[xX]/
              val[0][2..-1].to_i(16)
            elsif val[0] =~ /^0/
              val[0][1..-1].to_i(8)
            else
              val[0].to_i
            end
            result = LiteralMatcher.new(value)
          }
        | STRING {
            quote = val[0][0..0]
            value = if quote == "'"
              val[0][1..-2].gsub("\\\\", "\\").gsub("\\'", "'")
            elsif quote == '"'
              val[0][1..-2].
                gsub("\\\\", "\\").
                gsub('\\"', '"').
                gsub("\\n", "\n").
                gsub("\\t", "\t").
                gsub("\\r", "\r").
                gsub("\\f", "\f").
                gsub("\\v", "\v").
                gsub("\\a", "\a").
                gsub("\\e", "\e").
                gsub("\\b", "\b").
                gsub("\\s", "\s").
                gsub(/\\([0-7]{1,3})/) { $1.to_i(8).chr }.
                gsub(/\\x([0-9a-fA-F]{1,2})/) { $1.to_i(16).chr }
            else
              raise "Unknown quote: #{quote.inspect}."
            end
            result = LiteralMatcher.new(value)
          }

---- header

---- inner

include Matchers

class SyntaxError < StandardError; end

def parse(input)
  @input = input
  @pos = 0

  do_parse
end

private

SIMPLE_TOKENS = ["|", "<", ">", ",", "="]

# FIXME: The patterns for VAR_NAME, CLASS_NAME, SYMBOL tokens are simpler than
#        they should be. Implement them according to Ruby's parse.y (from
#        1.8.7-p352).
COMPLEX_TOKENS = [
  [:VAR_NAME,   /^[a-z_][a-zA-Z0-9_]*/],
  [:CLASS_NAME, /^[A-Z][a-zA-Z0-9_]*/],
  [:SYMBOL,     /^:[a-zA-Z_][a-zA-Z0-9_]*/],
  [
    :INTEGER,
    /^
      [+-]?                               # sign
      (
        0[bB][01]+(_[01]+)*               # binary (prefixed)
        |
        0[oO][0-7]+(_[0-7]+)*             # octal (prefixed)
        |
        0[dD]\d+(_\d+)*                   # decimal (prefixed)
        |
        0[xX][0-9a-fA-F]+(_[0-9a-fA-F]+)* # hexadecimal (prefixed)
        |
        0[0-7]*(_[0-7]+)*                 # octal (unprefixed)
        |
        [1-9]\d*(_\d+)*                   # decimal (unprefixed)
      )
    /x
  ],
  [
    :STRING,
    /^
      (
        '                 # sinqle-quoted string
          (
            \\[\\']           # escape
            |
            [^']              # regular character
          )*
        '
        |
        "                 # double-quoted string
          (
            \\                # escape
            (
              [\\"ntrfvaebs]    # one-character escape
              |
              [0-7]{1,3}        # octal number escape
              |
              x[0-9a-fA-F]{1,2} # hexadecimal number escape
            )
            |
            [^"]              # regular character
          )*
        "
      )
    /x
  ]
]

def next_token
  skip_whitespace

  return false if remaining_input.empty?

  SIMPLE_TOKENS.each do |token|
    if remaining_input[0...token.length] == token
      @pos += token.length
      return [token, token]
    end
  end

  COMPLEX_TOKENS.each do |type, regexp|
    if remaining_input =~ regexp
      @pos += $&.length
      return [type, $&]
    end
  end

  raise SyntaxError, "Unexpected character: #{remaining_input[0..0].inspect}."
end

def skip_whitespace
  if remaining_input =~ /^[ \t\r\n]+/
    @pos += $&.length
  end
end

def remaining_input
  @input[@pos..-1]
end

def on_error(error_token_id, error_value, value_stack)
  raise SyntaxError, "Unexpected token: #{error_value.inspect}."
end
