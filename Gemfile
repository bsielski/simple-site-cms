source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.5'
gem 'puma', '~> 4.3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 4.1.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5.1.0'
gem 'jbuilder', '~> 2.6'


# My gems
gem 'devise', '~> 4.7'
gem 'markdown'
gem 'reverse_markdown'
gem 'acts_as_list'
gem 'active_link_to'
gem "rolify"
gem "pundit"
gem 'will_paginate', '~> 3.1.0'
gem 'pg', '~> 1.0.0'

gem "trailblazer-cells", "~> 0.0.3"
gem "cells-rails", "~> 0.0.8"
gem "cells-erb", "~> 0.1.0"

gem "dry-validation", "0.11.0"
gem "trailblazer-rails", "~> 2.1.4"

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.18'
  gem 'selenium-webdriver', '~> 3.11.0'

  gem 'rspec-rails', '~> 3.7.2'
  gem 'pry-rails', '~> 0.3.6'
  gem "rspec-cells", "~> 0.3.4"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
