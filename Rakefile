require "rspec/core/rake_task"
require "yard"

desc "Generate the expression parser"
task :parser do
  source = "lib/machete/parser.y"
  target = "lib/machete/parser.rb"
  unless uptodate?(target, [source])
    sh "racc -o #{target} #{source}"
  end
end

RSpec::Core::RakeTask.new
task :spec => :parser

YARD::Rake::YardocTask.new
task :yard => :parser

task :default => :spec
