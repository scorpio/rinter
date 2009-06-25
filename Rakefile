require 'rubygems'
require 'rake/gempackagetask'
PKG_NAME = "rinterceptor"
PKG_VERSION = "0.2.0"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*'
]
spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "it is a inheritable, reusable AOP framework"
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.require_path = 'lib'
  s.homepage = %q{http://rinter.rubyforge.org/}
  s.rubyforge_project = 'Rinterceptor'
  s.has_rdoc = false
  s.authors = ["Leon Li"]
  s.email = "scorpio_leon@hotmail.com"
  s.files = PKG_FILES
  s.description = <<-EOF
    it is a inheritable, reusable AOP framework with regex rule support, let your interceptor simple, flexible and with high expandability
  EOF
end
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
