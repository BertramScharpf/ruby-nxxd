#
#  nxxd.gemspec  --  Gem Specification
#

require "./lib/nxxd/version"


Gem::Specification.new do |s|
  s.name        = "nxxd"
  s.version     = Nxxd::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = ">= 3.1"
  s.summary     = "Hex Dump Tool"
  s.description = <<~EOT
    Yet another Xxd reimplementation.
  EOT
  s.license     = "LicenseRef-LICENSE"

  s.authors,
  s.email       = (<<~EOT.scan /(\S.*\S)\s*<(.*)>/).transpose
    Bertram Scharpf <software@bertram-scharpf.de>
  EOT

  s.homepage    = "https://github.com/BertramScharpf/ruby-nxxd"

  s.requirements     = "Just Ruby"

  s.require_paths    = %w(lib)
  s.files            = Dir[ "lib/**/*.rb", "bin/*", ] +
                       %w(LICENSE README.md nxxd.gemspec)
  s.bindir           = "bin"
  s.extensions       = %w()
  s.executables      = %w(nxxd)
  s.extra_rdoc_files = %w()

end

