lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "excelsior/version"

Gem::Specification.new do |spec|
  spec.name          = "excelsior"
  spec.version       = Excelsior::VERSION
  spec.authors       = ["Immanuel Häussermann"]
  spec.email         = ["hai@panter.ch"]

  spec.summary       = %q{Helps you import data from an excel sheet}
  spec.description   = %q{Provides a concise DSL to map, validate and import data from an excel sheet into your ruby app}
  spec.homepage      = "http://github.com/manufaktor/excelsior"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3"

  spec.add_runtime_dependency "simple_xlsx_reader", "~> 1.0.2"
  spec.add_runtime_dependency "rails", ">= 4.0.0"
  spec.add_runtime_dependency "activerecord", ">= 4.0.0"
end
