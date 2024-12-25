# frozen_string_literal: true

require_relative "lib/npm_ext/version"

Gem::Specification.new do |spec|
  spec.name = "npm_ext"
  spec.version = NpmExt::VERSION
  spec.authors = ["Alexandra Østermark"]
  spec.email = ["alex.cramt@gmail.com"]
  spec.license = "MIT"

  spec.summary = ""
  spec.description = ""
  spec.homepage = "https://github.com/cramt/npm_ext"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_racer", "0.6.2"
end
