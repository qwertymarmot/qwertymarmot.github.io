# Test plugin to verify Jekyll is loading plugins

puts "Test plugin loaded"

Jekyll::Hooks.register :site, :after_init do |site|
  puts "Test plugin hook executed"
  
  # Create a test file
  FileUtils.mkdir_p(site.dest) unless File.directory?(site.dest)
  File.write(File.join(site.dest, 'test_plugin.txt'), "Test plugin executed at #{Time.now}")
end
