# frozen_string_literal: true

require_relative "lib/cmdtabs/version"

Gem::Specification.new do |spec|
  spec.name          = "cmdtabs"
  spec.version       = Cmdtabs::VERSION
  spec.authors       = ["seoanezonjic"]
  spec.email         = ["seoanezonjic@hotmail.com"]

  spec.summary       = "DEPRECATED PROJECT. MIGRATED TO PYTHON: https://github.com/seoanezonjic/py_cmdtabs\nGem to manipulate text tables in cmd"
  spec.description   = "Toolset to merge, colapse tables rename field contents, etc "
  spec.homepage      = "https://github.com/seoanezonjic/cmdtabs"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "xsv"
  
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
