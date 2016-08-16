# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/sdk/iam_action_simplifier/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-sdk-iam_action_simplifier"
  spec.version       = Aws::Sdk::IamActionSimplifier::VERSION
  spec.authors       = ["Drew J. Sonne"]
  spec.email         = ["drew.sonne@gmail.com"]

  spec.summary       = %q{Gem handling the consolidation of IAM actions.}
  spec.description   = %q{Given a list of actions, this library will try to simplify the action list.}
  spec.homepage      = "https://github.com/drewsonne/aws-sdk-iam_action_simplifier"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
