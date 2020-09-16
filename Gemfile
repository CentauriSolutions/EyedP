# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'acts_as_tree'

# Supported DBs
# TODO: add MySQL support -
# gem 'mysql2', '~> 0.4.10', group: :mysql
gem 'pg', '~> 1.1', group: :postgresql

gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0'
gem 'sass-rails', '~> 6.0'

gem 'bcrypt', '>= 3.1.13'
gem 'uglifier', '>= 1.3.0'

gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 4.0'
# gem 'turbolinks', '~> 5'

gem 'bootsnap', '>= 1.3.2', require: false

gem 'rails-i18n'
gem 'dotenv', '~> 2.5.0'

gem 'devise'
gem 'devise-i18n'
gem 'devise_fido_usf'
gem 'friendly_id'
# Do TOTP 2FA
gem 'devise-two-factor'
gem 'rqrcode'

# Translations
gem 'translation'

gem 'bootstrap', '~> 4.4.1'
gem 'bootstrap_form', '>= 4.2.0'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'will_paginate'
gem 'will_paginate-bootstrap4'

gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'scout_apm'

# gem 'ledermann-rails-settings'
# gem 'rails-settings-cached'

gem 'peek'
gem 'peek-pg'
gem 'peek-performance_bar'
gem 'tipsy-rails'
gem 'peek-gc'

# SAML the things!
gem 'saml_idp'

gem 'chartkick'
gem 'groupdate'

gem 'liquid'

group :development, :test do
  gem 'coveralls', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 4'
end

group :development do
  gem 'listen', '>= 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate'
  gem 'awesome_print'
  gem 'bullet'
  gem 'rails-erd'

  gem 'brakeman', require: false
  gem 'overcommit'
  gem 'rubocop', require: false

  gem 'guard'
  gem 'guard-bundler', require: false
  # gem 'guard-livereload', require: false
  # gem 'rack-livereload'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console', '>= 3.3.0'

  gem 'bcrypt_pbkdf',       require: false
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano3-puma',   require: false
  gem 'ed25519',            require: false
end

group :test do
  gem 'faker'
  gem 'timecop'
  gem 'shoulda'
end
