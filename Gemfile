# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.27.4"
gem "decidim-centers", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 4.3"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", "0.27.4"
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker", "~> 1.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "codecov", require: false
end
