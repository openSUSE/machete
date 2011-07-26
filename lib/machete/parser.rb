#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


module Machete
  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 44)

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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    10,     2,     3,     4,     5,    17,    18,    11,     2,     3,
     4,     5,     2,     3,     4,     5,     9,    14,    15,    19,
    14,    11 ]

racc_action_check = [
     6,     0,     0,     0,     0,    12,    12,     6,    11,    11,
    11,    11,    19,    19,    19,    19,     2,     9,    10,    14,
    18,    21 ]

racc_action_pointer = [
    -2,   nil,     8,   nil,   nil,   nil,     0,   nil,   nil,    15,
    18,     5,    -4,   nil,     8,   nil,   nil,   nil,    18,     9,
   nil,    14 ]

racc_action_default = [
   -13,    -4,    -5,   -10,   -11,   -12,   -13,    -1,    -3,   -13,
   -13,   -13,   -13,    -7,   -13,    22,    -2,    -6,   -13,   -13,
    -8,    -9 ]

racc_goto_table = [
     6,    13,    16,    12,   nil,   nil,   nil,   nil,   nil,   nil,
    20,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    21 ]

racc_goto_check = [
     1,     6,     2,     5,   nil,   nil,   nil,   nil,   nil,   nil,
     6,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     1 ]

racc_goto_pointer = [
   nil,     0,    -9,   nil,   nil,    -6,    -8 ]

racc_goto_default = [
   nil,   nil,     7,     8,     1,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 13, :_reduce_none,
  3, 13, :_reduce_2,
  1, 14, :_reduce_none,
  1, 14, :_reduce_none,
  1, 15, :_reduce_5,
  4, 15, :_reduce_6,
  1, 17, :_reduce_none,
  3, 17, :_reduce_8,
  3, 18, :_reduce_9,
  1, 16, :_reduce_10,
  1, 16, :_reduce_11,
  1, 16, :_reduce_12 ]

racc_reduce_n = 13

racc_shift_n = 22

racc_token_table = {
  false => 0,
  :error => 1,
  :VAR_NAME => 2,
  :CLASS_NAME => 3,
  :SYMBOL => 4,
  :INTEGER => 5,
  :STRING => 6,
  "|" => 7,
  "<" => 8,
  ">" => 9,
  "," => 10,
  "=" => 11 }

racc_nt_base = 12

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "VAR_NAME",
  "CLASS_NAME",
  "SYMBOL",
  "INTEGER",
  "STRING",
  "\"|\"",
  "\"<\"",
  "\">\"",
  "\",\"",
  "\"=\"",
  "$start",
  "expression",
  "primary",
  "node",
  "literal",
  "attrs",
  "attr" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'parser.y', 14)
  def _reduce_2(val, _values, result)
                   result = if val[0].is_a?(ChoiceMatcher)
                 ChoiceMatcher.new(val[0].alternatives << val[2])
               else
                 ChoiceMatcher.new([val[0], val[2]])
               end
             
    result
  end
.,.,

# reduce 3 omitted

# reduce 4 omitted

module_eval(<<'.,.,', 'parser.y', 25)
  def _reduce_5(val, _values, result)
             result = NodeMatcher.new(val[0].to_sym)
       
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 28)
  def _reduce_6(val, _values, result)
             result = NodeMatcher.new(val[0].to_sym, val[2])
       
    result
  end
.,.,

# reduce 7 omitted

module_eval(<<'.,.,', 'parser.y', 32)
  def _reduce_8(val, _values, result)
     result = val[0].merge(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 34)
  def _reduce_9(val, _values, result)
     result = { val[0].to_sym => val[2] } 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 36)
  def _reduce_10(val, _values, result)
     result = LiteralMatcher.new(val[0][1..-1].to_sym) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 37)
  def _reduce_11(val, _values, result)
     result = LiteralMatcher.new(val[0].to_i)          
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 38)
  def _reduce_12(val, _values, result)
     result = LiteralMatcher.new(val[0][1..-2])        
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

  end   # class Parser
  end   # module Machete
