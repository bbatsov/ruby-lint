desc 'Builds and signs a new Gem'
task :signed_build => [:build] do
  name = "#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
  path = File.join(File.expand_path('../../pkg', __FILE__), name)

  sh("gem sign #{path}")

  Rake::Task['checksum'].invoke
end
