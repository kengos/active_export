# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_export/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["kengos"]
  gem.email         = ["kengo@kengos.jp"]
  gem.description   = %q{export to csv}
  gem.summary       = %q{export to csv}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)

  gem.add_dependency("activesupport", ">= 3.0.0")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "active_export"
  gem.require_paths = ["lib"]
  gem.version       = ActiveExport::VERSION
end
