Machete
=======

Machete is a simple tool for matching Rubinius AST nodes against patterns. You can use it if you are writing any kind of tool that processes Ruby code and needs to do some work on specific types of nodes, needs to find patterns in the code, etc.

Installation
------------

You need to install [Rubinius](http://rubini.us/) first. You can then install Machete:

    $ gem install machete

Usage
-----

First, require the library:

    require "machete"

You can now use one of two methods Machete offers: `Machete.matches?` and `Machete.find`.

The `Machete.matches?` method matches a Rubinus AST node against a pattern:

    Machete.matches?('foo.bar'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
    # => true

    Machete.matches?('42'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
    # => false

(See below for pattern syntax description.)

The `Machete.find` method finds all nodes in a Rubinius AST tree matching a pattern:

    Machete.find('42 + 43 + 44'.to_ast, 'FixnumLiteral')
    # => [
    #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
    #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
    #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
    #    ]

    compiled_pattern = Machete::Parser.new.parse('FixnumLiteral')
    Machete.find('42 + 43 + 44'.to_ast, compiled_pattern)
    # => [
    #      #<Rubinius::AST::FixnumLiteral:0x10b0 @value=44 @line=1>,
    #      #<Rubinius::AST::FixnumLiteral:0x10b8 @value=43 @line=1>,
    #      #<Rubinius::AST::FixnumLiteral:0x10c0 @value=42 @line=1>
    #    ]

Pattern Syntax
--------------

### Basics

Rubinius AST consists of instances of classes that represent various types of nodes:

    '42'.to_ast     # => #<Rubinius::AST::FixnumLiteral:0xf28 @value=42 @line=1>
    '"abcd"'.to_ast # => #<Rubinius::AST::StringLiteral:0xf60 @line=1 @string="abcd">

To match a specific node type, just use its class name in the pattern:

    Machete.matches?('42'.to_ast,     'FixnumLiteral') # => true
    Machete.matches?('"abcd"'.to_ast, 'FixnumLiteral') # => false

To specify multiple alternatives, use the choice operator:

    Machete.matches?('42'.to_ast,     'FixnumLiteral | StringLiteral') # => true
    Machete.matches?('"abcd"'.to_ast, 'FixnumLiteral | StringLiteral') # => true

If you don't care about the node type at all, use the `any` keyword (this is most useful when matching arrays — see below):

    Machete.matches?('42'.to_ast,     'any') # => true
    Machete.matches?('"abcd"'.to_ast, 'any') # => true

### Node Attributes

If you want to match a specific attribute of a node, specify its value inside `<...>` right after the node name:

    Machete.matches?('42'.to_ast, 'FixnumLiteral<value = 42>') # => true
    Machete.matches?('45'.to_ast, 'FixnumLiteral<value = 42>') # => false

The attribute value can be `true`, `false`, `nil`, integer, string, symbol, array or other pattern. The last option means you can easily match nested nodes recursively. You can also specify multiple attributes:

    Machete.matches?('foo.bar'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>') # => true

#### String Attributes

When matching string attributes values, you don't have to do a whole-string match using the `=` operator. You can also match the beginning, the end or a part of a string attribute value using the `^=`, `$=` and `*=` operators:

    Machete.matches?('"abcd"'.to_ast, 'StringLiteral<string ^= "ab">') # => true
    Machete.matches?('"efgh"'.to_ast, 'StringLiteral<string ^= "ab">') # => false
    Machete.matches?('"abcd"'.to_ast, 'StringLiteral<string $= "cd">') # => true
    Machete.matches?('"efgh"'.to_ast, 'StringLiteral<string $= "cd">') # => false
    Machete.matches?('"abcd"'.to_ast, 'StringLiteral<string *= "bc">') # => true
    Machete.matches?('"efgh"'.to_ast, 'StringLiteral<string *= "bc">') # => false

#### Array Attributes

When matching array attribute values, the simplest way is to specify the array elements exactly. They will be matched one-by-one.

    Machete.matches?('[1, 2]'.to_ast, 'ArrayLiteral<body = [FixnumLiteral<value = 1>, FixnumLiteral<value = 2>]>') # => true

If you don't care about the node type of some array elements, you can use `any`:

    Machete.matches?('[1, 2]'.to_ast,      'ArrayLiteral<body = [any, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('["abcd", 2]'.to_ast, 'ArrayLiteral<body = [any, FixnumLiteral<value = 2>]>') # => true

The best thing about array matching is that you can use quantifiers for elements: `*`, `+`, `?`, `{n}`, `{n,}`, `{,n}`, `{m,n}`. Their meaning is the same as in Perl-like regular expressions:

    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any*, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any*, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any*, FixnumLiteral<value = 2>]>') # => true
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any+, FixnumLiteral<value = 2>]>') # => false
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any+, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any+, FixnumLiteral<value = 2>]>') # => true
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any?, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any?, FixnumLiteral<value = 2>]>') # => true
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any{1}, FixnumLiteral<value = 2>]>') # => false
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{1}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{1}, FixnumLiteral<value = 2>]>') # => false
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any{1,}, FixnumLiteral<value = 2>]>') # => false
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{1,}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{1,}, FixnumLiteral<value = 2>]>') # => true
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any{,1}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{,1}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{,1}, FixnumLiteral<value = 2>]>') # => false
    
    Machete.matches?('[2]'.to_ast,          'ArrayLiteral<body = [any{1,2}, FixnumLiteral<value = 2>]>') # => false
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{1,2}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{1,2}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 1, 2]'.to_ast, 'ArrayLiteral<body = [any{1,2}, FixnumLiteral<value = 2>]>') # => false

There are also two unusual quantifiers: `{even}` and `{odd}`. They specify that the quantified expression must repeat even or odd number of times:

    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{even}, FixnumLiteral<value = 2>]>') # => false
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{even}, FixnumLiteral<value = 2>]>') # => true
    
    Machete.matches?('[1, 2]'.to_ast,       'ArrayLiteral<body = [any{odd}, FixnumLiteral<value = 2>]>') # => true
    Machete.matches?('[1, 1, 2]'.to_ast,    'ArrayLiteral<body = [any{odd}, FixnumLiteral<value = 2>]>') # => false

These quantifiers are best used when matching hashes containing a specific key or value. This is because in Rubinius AST both hash keys and values are flattened into one array and the only thing distinguishing them is even or odd position.

### More Information

For more details about the syntax see the `lib/machete/parser.y` file which contains the pattern parser.

FAQ
---

**Why did you chose Rubinius AST as a base? Aren't there other tools for Ruby parsing which are not VM-specific?**

There are three other tools which were considered but each has its issues:

* [parse_tree](http://parsetree.rubyforge.org/) — unmaintained and unsupported for 1.9
* [ruby_parser](http://parsetree.rubyforge.org/) — sometimes reports wrong line numbers for the nodes (this is a killer for some use cases)
* [Ripper](http://rubyforge.org/projects/ripper/) — usable but the generated AST is too low level (the patterns would be too complex and low-level)

Rubinius AST is also by far the easiest to work with.

Acknowledgement
---------------

The general idea and inspiration for the pattern syntax was taken form Python's [2to3](http://docs.python.org/library/2to3.html) tool.
