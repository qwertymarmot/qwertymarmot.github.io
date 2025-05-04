source "https://rubygems.org"

# Use GitHub Pages with a specific version
gem "github-pages", "~> 228", group: :jekyll_plugins

# Specify Jekyll version explicitly
gem "jekyll", "~> 3.9.3"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.15.1"
  gem "jekyll-seo-tag", "~> 2.8.0"
  gem "jekyll-sitemap", "~> 1.4.0"
  gem "jekyll-relative-links", "~> 0.6.1"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.0", :install_if => Gem.win_platform?

# kramdown v2 ships without the gfm parser by default. If you're using
# kramdown v1, comment out this line.
gem "kramdown-parser-gfm", "~> 1.1.0"

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# For local development
gem "webrick", "~> 1.7"

# Explicitly specify ffi version to avoid compatibility issues
gem "ffi", "~> 1.15.5"

# Explicitly specify eventmachine version
gem "eventmachine", "~> 1.2.7"
