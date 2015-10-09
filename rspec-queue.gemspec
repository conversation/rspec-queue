spec = Gem::Specification.new do |s|
  s.name = 'rspec-queue'
  s.version = '0.0.1'
  s.summary = 'parallel rspec runner'
  s.authors = [""]

  s.bindir = 'bin'
  s.executables << 'rspec-queue'
  s.executables << 'rspec-queue-worker'

  s.add_dependency 'rspec', '>= 3.0'
  s.add_development_dependency 'pry-nav'
end
