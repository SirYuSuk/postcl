lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "postcl/version"

Gem::Specification.new do |spec|
  spec.name          = "postcl"
  spec.version       = PostCL::VERSION
  spec.authors       = ["flevosap", "maximvdberg"]
  spec.email         = ["info@bami.party"]

  spec.summary       = %q{PostCL is een simpel terminal-script waarmee informatie een PostNL-zending opgevraagd kan worden.}
#   spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://postcl.bami.party"

#   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SirYuSuk/postcl"
  spec.metadata["changelog_uri"] = "https://github.com/SirYuSuk/postcl/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|dev)/}) }
  end

  spec.executables   << "postcl"
  spec.require_paths = ["lib"]


  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "docopt", "~> 0.6.1"
  spec.add_dependency "httparty", "~> 0.17.0"
  spec.add_dependency "terminal-table", "~> 1.8.0"
  spec.add_dependency "tty-prompt", "~> 0.19.0"
  spec.add_dependency "tty-spinner", "~> 0.9.1"
end
