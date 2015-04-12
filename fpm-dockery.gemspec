# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fpm/dockery/version'

Gem::Specification.new do |spec|
  spec.name          = "fpm-dockery"
  spec.version       = Fpm::Dockery::VERSION
  spec.authors       = ["Andy Sykes"]
  spec.email         = ["github@tinycat.co.uk"]

  spec.summary       = %q{Build fpm-cookery recipes with Docker!}
  spec.description   = %q{Use Docker to produce clean builds of fpm-cookery recipes by building in containers}
  spec.homepage      = "https://github.com/andytinycat/fpm-dockery"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "clamp", "~> 0.6.4"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
