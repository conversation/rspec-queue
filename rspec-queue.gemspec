spec = Gem::Specification.new do |s|
  s.name = 'rspec-queue'
  s.version = '0.3.0'
  s.licenses = ['MIT']
  s.summary = 'parallel rspec runner'
  s.authors = ["Nick Browne"]
  s.homepage = "http://github.com/conversation/rspec-queue"

  s.bindir = 'bin'
  s.files = `git ls-files -- lib/*`.split("\n")
  s.executables << 'rspec-queue'
  s.executables << 'rspec-queue-worker'

  s.add_dependency 'rspec-core', '>= 3.2'
  s.add_development_dependency 'rspec'
end
