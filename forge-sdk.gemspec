Gem::Specification.new do |s|
  s.name        = "forge-sdk"
  s.version     = "0.1.0"
  s.summary     = "Ruby SDK for the Forge rendering engine"
  s.description = "HTTP client for Forge. Converts HTML/CSS to PDF, PNG, and other formats."
  s.authors     = ["Centrix Systems"]
  s.email       = ["dev@centrix.systems"]
  s.homepage    = "https://github.com/centrixsystems/forge-sdk-ruby"
  s.license     = "MIT"

  s.files       = Dir["lib/**/*.rb"] + ["LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.0"

  s.add_dependency "net-http"
  s.add_dependency "json"
end
