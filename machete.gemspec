# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + "/lib/machete/version")

Gem::Specification.new do |s|
  s.name        = "machete"
  s.version     = Machete::VERSION
  s.summary     = "Simple tool for matching Rubinius AST nodes against patterns"
  s.description = <<-EOT.split("\n").map(&:strip).join(" ")
    Machete is a simple tool for matching Rubinius AST nodes against patterns.
    You can use it if you are writing any kind of tool that processes Ruby code
    and needs to do some work on specific types of nodes, needs to find patterns
    in the code, etc.
  EOT

  s.authors     = ["David Majda", "Piotr Niełacny"]
  s.email       = ["dmajda@suse.cz", "piotr.nielacny@gmail.com"]
  s.homepage    = "https://github.com/openSUSE/machete"
  s.license     = "MIT"

  s.files       = `git ls-files`.split("\n") + ["lib/machete/parser.rb"]

  s.add_development_dependency "racc"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rdiscount"
  s.add_development_dependency "yard"
end
