require 'rspec/core/rake_task'

desc 'Run the specs'
RSpec::Core::RakeTask.new do |r|
  r.verbose = false
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib"
end

task :build do
  puts `gem build transactor.gemspec`

task :push do
  require 'transactors/version'
  puts `gem push transactor-#{Transactor::VERSION}.gem`
end

task release: [:build, :push] do
  puts `rm -f transactor*.gem`
end

task :default => :spec
