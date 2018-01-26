# -*- encoding: utf-8 -*-
require "./lib/yamlconfig/version"

Gem::Specification.new do |s|
  s.name              = "yamlconfig"
  s.version           = "0.0.1"
  s.authors           = ["sent-hil"]
  s.email             = ["me@sent-hil.com"]
  s.homepage          = "https://github.com/sent-hil/ruby-yamlconfig"
  s.description       = %q{}
  s.summary           = %q{}

  s.rubyforge_project = "ruby-yamlconfig"

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end

  s.require_paths     = ["lib"]

  s.add_dependency "yaml"

  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"
end
