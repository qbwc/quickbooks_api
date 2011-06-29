spec = Gem::Specification.new do |s|
  s.name = 'quickbooks_api'
  s.version = '0.1.0'

  s.summary = "QuickBooks XML API"
  s.description = %{A QuickBooks QBXML wrapper for Ruby}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] + 
            Dir['xml_schema/*.xml'] + Dir['sample_data/*.xml'] + 
            ["README", "TODO"]
  s.require_path = 'lib'
  s.author = "Alex Skryl"
  s.email = "rut216@gmail.com"
  s.homepage = "http://github.com/skryl"

  s.add_dependency(%q<activesupport>, [">= 0"])
  s.add_dependency(%q<nokogiri>, [">= 0"])
end
