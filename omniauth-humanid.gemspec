version = '0.0.5'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-humanid"
  spec.version       = version
  spec.authors       = ["Luke Clancy"]
  spec.email         = ["lukeclancy@hotmail.com"]

  spec.summary       = %q{omniauth-humanid is an omniauth strategy for humanID, a company that provides bot-adverse and private signup functionality. Tested with the devise and omniauth gem}
  spec.homepage      = "https://github.com/LukeClancy/omniauth-humanid/blob/master/README.md"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/LukeClancy/omniauth-humanid"
  spec.metadata["changelog_uri"] = "https://github.com/LukeClancy/omniauth-humanid/blob/master/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  
  #Note: is this magic?

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
