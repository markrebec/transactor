$:.push File.expand_path("../lib", __FILE__)
require "transactor/version"

Gem::Specification.new do |s|
  s.name        = "transactor"
  s.version     = Transactor::VERSION
  s.summary     = "Transactional actors for easy rollbacks"
  s.description = "Transactional actors for easy rollbacks"
  s.authors     = ["Mark Rebec"]
  s.email       = ["mark@markrebec.com"]
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["spec/**/*"]
  s.homepage    = "http://github.com/markrebec/transactor"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
