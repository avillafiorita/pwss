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
  spec.description   = %q{PWSS is a command-line password manager, in the spirit of pws
Distinguishing features:
- the command manages different password files
- a password file can store multiple entries
- entries are of different types (Entry, CreditCard, BankAccount)
- each type stores specific information (e.g., name, card_number for CreditCards)
- a password file can be encrypted or in plain text (if you wish to do so)
- decrypt and encrypt commands allow to edit password files directly
}
  spec.homepage      = "http://www.github.com/avillafiorita/pwss"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'slop', '~> 3.6.0', '>= 3.6.0'
  spec.add_runtime_dependency 'encryptor', '~> 1.3.0', '>= 1.3.0'     
end
