Gem::Specification.new do |s|
  s.name         = 'quickbooks_api'
  s.version      = '0.1.6.1'

  s.summary      = "QuickBooks XML API"
  s.description  = %{A QuickBooks QBXML wrapper for Ruby}

  s.author       = "Alex Skryl"
  s.email        = "rut216@gmail.com"
  s.homepage     = "http://github.com/skryl"
  s.files        = `git ls-files`.split($/)
  s.require_paths = ["lib"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  
  
  s.add_dependency(%q<activesupport>, [">= 0"])
  s.add_dependency(%q<nokogiri>, [">= 0"])
  s.add_dependency(%q<buffered_logger>, [">= 0.1.3"])
end
