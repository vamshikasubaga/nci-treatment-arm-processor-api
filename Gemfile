source 'https://rubygems.org'

gem 'newrelic_rpm'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'

# Use Puma as the app server
gem 'puma'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'aws-record'
gem 'aws-sdk', '2.6.34'
gem 'aws-sdk-rails', '1.0.1'
gem 'shoryuken', '2.0.11'

gem 'httparty', '0.14.0'
gem 'nci_match_patient_models', git: 'git://github.com/CBIIT/nci-match-lib.git', branch: 'master'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'simplecov-rcov'
  gem 'spring'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  gem 'codacy-coverage', require: false
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'simplecov'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
