# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "impact_score"
  spec.version       = File.read(File.join(__dir__, "lib", "impact_score", "version.rb")).match(/VERSION\s*=\s*"([^"]+)"/)[1]
  spec.summary       = "Compute engineering impact scores from CSV with tunable weights"
  spec.description   = "CLI and library for computing engineering impact scores and comparisons from CSV exports."
  spec.homepage      = "https://github.com/emmahyde/impact-score-cli"
  spec.license       = "MIT"

  spec.author        = "Emma Hyde"
  spec.email         = "emmajhyde@gmail.com"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE", "impact_score.gemspec"]
  spec.bindir        = "bin"
  spec.executables   = ["impact-score"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_development_dependency "rake"
end
