require File.expand_path('../lib/omniauth-copy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Schuyler Ullman"]
  gem.email         = ["schuyler.ullman@gmail.com"]
  gem.description   = %q{Unofficial OmniAuth strategy for Copy.com.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/plexinc/omniauth-copy"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-copy"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Copy::VERSION

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth', '~> 1.1'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
end
