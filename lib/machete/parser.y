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

attr : VAR_NAME "=" primary { result = { val[0].to_sym => val[2] } }

literal : SYMBOL  { result = LiteralMatcher.new(val[0][1..-1].to_sym) }
        | INTEGER { result = LiteralMatcher.new(val[0].to_i)          }
        | STRING  { result = LiteralMatcher.new(val[0][1..-2])        }

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

# FIXME: The patterns for VAR_NAME, CLASS_NAME, SYMBOL and INTEGER tokens are
#        simpler than they should be. Implement them according to Ruby's parse.y
#        (from 1.8.7-p352).
COMPLEX_TOKENS = [
  [:VAR_NAME,   /^[a-z_][a-zA-Z0-9_]*/],
  [:CLASS_NAME, /^[A-Z][a-zA-Z0-9_]*/],
  [:SYMBOL,     /^:[a-zA-Z_][a-zA-Z0-9_]*/],
  [:INTEGER,    /^[+-]?\d+/],
  [:STRING,     /^('[^']*'|"[^"]*")/]
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
