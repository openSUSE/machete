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

Pattern Syntax
--------------

Rubinius AST consists of instances of classes that represent various types of nodes:

    '42'.to_ast     # => #<Rubinius::AST::FixnumLiteral:0xf28 @value=42 @line=1>
    '"abcd"'.to_ast # => #<Rubinius::AST::StringLiteral:0xf60 @line=1 @string="abcd">

To match a specific node type, just use its class name in the pattern:

    Machete.matches?('42'.to_ast,     'FixnumLiteral') # => true
    Machete.matches?('"abcd"'.to_ast, 'FixnumLiteral') # => false

If you want to match specific attribute of the node, specify its value inside `<...>` right after the node name:

    Machete.matches?('42'.to_ast, 'FixnumLiteral<value = 42>') # => true
    Machete.matches?('45'.to_ast, 'FixnumLiteral<value = 42>') # => false

The attribute value can be an integer, string, symbol or other pattern. This means you can easily match nested nodes recursively. You can also specify multiple attributes:

    Machete.matches?('foo.bar'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
    # => true

    Machete.matches?('42'.to_ast, 'Send<receiver = Send<receiver = Self, name = :foo>, name = :bar>')
    # => false

To specify multiple alternatives, use the choice operator:

    Machete.matches?('42'.to_ast,     'FixnumLiteral | StringLiteral') # => true
    Machete.matches?('"abcd"'.to_ast, 'FixnumLiteral | StringLiteral') # => true

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
