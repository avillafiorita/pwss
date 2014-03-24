# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pwss/version'

Gem::Specification.new do |spec|
  spec.name          = "pwss"
  spec.version       = Pwss::VERSION
  spec.authors       = ["Adolfo Villafiorita"]
  spec.email         = ["adolfo.villafiorita@me.com"]
  spec.summary       = %q{A password manager in the spirit of pwss}
  spec.description   = %q{PWSS is a password safe, in the spirit of pws
Distinguishing features:
- all entries are stored in a single file
- entries are "complex" records, with username, password, url, description
- the safe file can be stored encrypted or not
- decrypt and encrypt command allow to operate directly on the password file
}
  spec.homepage      = "http://www.github.com/avillafiorita/pwss"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'mercenary', '~> 0.3.2', '>= 0.3.2'
  spec.add_runtime_dependency 'encryptor', '~> 1.3.0', '>= 1.3.0'     
end
