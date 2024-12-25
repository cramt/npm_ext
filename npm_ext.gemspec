# frozen_string_literal: true

require_relative "lib/npm_ext/version"

Gem::Specification.new do |spec|
  spec.name = "npm_ext"
  spec.version = NpmExt::VERSION
  spec.authors = ["Alexandra Østermark"]
  spec.email = ["alex.cramt@gmail.com"]

  spec.summary = ""
  spec.description = ""
  spec.homepage = "https://github.com/cramt/npm_ext"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_racer", "0.6.2"
end
