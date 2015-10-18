# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pwss/version'

Gem::Specification.new do |spec|
  spec.name          = "pwss"
  spec.version       = Pwss::VERSION
  spec.authors       = ["Adolfo Villafiorita"]
  spec.email         = ["adolfo.villafiorita@me.com"]

  spec.summary       = %q{A password manager in the spirit of pass and pws}
  spec.description   = %q{PWSS is a command-line password manager, in the spirit of pws
Distinguishing features:
- pwss manages different password files
- a password file can store multiple entries
- entries can be of different types (e.g., Entry, CreditCard, BankAccount)
- each type stores specific information (e.g., card_number for CreditCards)
- a password file can be encrypted or stored in plain text (if you wish to do so)
- decrypt and encrypt commands allow one to edit password files with a text editor
- clipboard integration
- multi-platform
}
  spec.homepage      = "http://www.github.com/avillafiorita/pwss"
  spec.license       = "MIT"


  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"

  spec.add_runtime_dependency 'slop', '~> 4.3.0', '>= 4.3.0'
  spec.add_runtime_dependency 'encryptor', '~> 1.3.0', '~> 1.3.0'     
  spec.add_runtime_dependency 'clipboard', '~> 1.0.6', '>= 1.0.6'     
  spec.add_runtime_dependency 'gpgme', '~> 2.0.12', '>= 2.0.12'
end
